import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/discovery_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({HomeRepository? repository})
      : _repository = repository ?? const HomeRepository(),
        super(const HomeState()) {
    on<HomeLoaded>(_onLoaded);
    on<HomePostFollowToggled>(_onFollowToggled);
    on<HomePostLikeToggled>(_onLikeToggled);
    on<HomeNotificationDismissed>(_onNotificationDismissed);
  }

  final HomeRepository _repository;

  Future<void> _onLoaded(HomeLoaded event, Emitter<HomeState> emit) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));

    try {
      final posts = await _repository.getFeedPosts();
      final cards = await _repository.getHighlightCards();
      final notifications = await _repository.getNotifications();

      emit(
        state.copyWith(
          posts: posts,
          highlightCards: cards,
          notifications: notifications,
          status: HomeStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: 'Could not load your feed.',
      ));
    }
  }

  /// POST /expert/discover/providers/{type}/{id}/follow
  ///
  /// This used to flip the flag in memory only, so the button changed
  /// and then snapped back on the next refresh - nothing was ever sent
  /// to the server.
  ///
  /// Following is per PROVIDER, not per post: following one post's
  /// author follows every post of theirs, so all their rows in the feed
  /// update together.
  Future<void> _onFollowToggled(
    HomePostFollowToggled event,
    Emitter<HomeState> emit,
  ) async {
    final matches = state.posts.where((post) => post.id == event.postId);
    if (matches.isEmpty) return;

    final target = matches.first;

    if (target.providerType.isEmpty || target.providerId.isEmpty) {
      // A post from the `getMyPosts` fallback has no provider identity;
      // it is the expert's own post, which they cannot follow anyway.
      return;
    }

    List<PostModel> withFollow(bool value) => state.posts
        .map((post) => post.providerType == target.providerType &&
                post.providerId == target.providerId
            ? post.copyWith(isFollowing: value)
            : post)
        .toList();

    // Optimistic, then corrected by whatever the server reports.
    emit(state.copyWith(posts: withFollow(!target.isFollowing)));

    try {
      final followed = await const DiscoveryRepository().toggleFollowByType(
        providerType: target.providerType,
        id: target.providerId,
      );

      emit(state.copyWith(posts: withFollow(followed)));
    } catch (_) {
      emit(state.copyWith(posts: withFollow(target.isFollowing)));
    }
  }

  /// Liking is a customer action (`POST /customer/posts/{id}/like`)
  /// with no expert equivalent, so this stays local to the session
  /// rather than pretending to persist.
  void _onLikeToggled(HomePostLikeToggled event, Emitter<HomeState> emit) {
    final updated = state.posts.map((post) {
      if (post.id == event.postId) {
        final liked = !post.isLiked;
        return post.copyWith(
          isLiked: liked,
          likesCount: liked ? post.likesCount + 1 : post.likesCount - 1,
        );
      }
      return post;
    }).toList();
    emit(state.copyWith(posts: updated));
  }

  void _onNotificationDismissed(
    HomeNotificationDismissed event,
    Emitter<HomeState> emit,
  ) {
    final updated = state.notifications
        .where((n) => n.id != event.notificationId)
        .toList();
    emit(state.copyWith(notifications: updated));
  }
}