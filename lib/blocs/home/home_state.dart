import 'package:equatable/equatable.dart';
import '../../data/models/highlight_card_model.dart';
import '../../data/models/post_model.dart';

enum HomeStatus { initial, loading, loaded, failure }

class HomeState extends Equatable {
  const HomeState({
    this.posts = const [],
    this.highlightCards = const [],
    this.notifications = const [],
    this.status = HomeStatus.initial,
    this.errorMessage,
  });

  final List<PostModel> posts;
  final List<HighlightCardModel> highlightCards;
  final List<HomeNotificationModel> notifications;
  final HomeStatus status;
  final String? errorMessage;

  bool get isEmpty => status == HomeStatus.loaded && posts.isEmpty;

  HomeState copyWith({
    List<PostModel>? posts,
    List<HighlightCardModel>? highlightCards,
    List<HomeNotificationModel>? notifications,
    HomeStatus? status,
    String? errorMessage,
  }) {
    return HomeState(
      posts: posts ?? this.posts,
      highlightCards: highlightCards ?? this.highlightCards,
      notifications: notifications ?? this.notifications,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [posts, highlightCards, notifications, status, errorMessage];
}
