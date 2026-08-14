import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/salon_model.dart';
import '../../data/repositories/discovery_repository.dart';
import 'salon_detail_event.dart';
import 'salon_detail_state.dart';

class SalonDetailBloc extends Bloc<SalonDetailEvent, SalonDetailState> {
  SalonDetailBloc({DiscoveryRepository? discovery})
      : _discovery = discovery ?? const DiscoveryRepository(),
        super(const SalonDetailState()) {
    on<SalonDetailLoaded>(_onLoaded);
    on<SalonDetailTabChanged>(_onTabChanged);
    on<SalonFollowToggled>(_onFollowToggled);
  }

  final DiscoveryRepository _discovery;

  /// `GET /expert/discover/providers/{type}/{id}` returns the profile,
  /// services, posts and reviews in one call, which is exactly the
  /// three tabs this screen renders.
  ///
  /// The reviews here are the PROVIDER's own, which is the whole point:
  /// the previous version called `GET /expert/reviews` and would have
  /// shown the signed-in expert's ratings on someone else's page.
  Future<void> _onLoaded(
    SalonDetailLoaded event,
    Emitter<SalonDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: SalonDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      final detail = await _discovery.getProvider(
        type: event.type,
        id: event.salonId,
      );

      emit(
        state.copyWith(
          salon: detail.salon,
          services: detail.services,
          posts: detail.posts,
          reviews: detail.reviews,
          status: SalonDetailStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: SalonDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SalonDetailStatus.failure,
        errorMessage: 'Could not load this provider.',
      ));
    }
  }

  void _onTabChanged(
    SalonDetailTabChanged event,
    Emitter<SalonDetailState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  Future<void> _onFollowToggled(
    SalonFollowToggled event,
    Emitter<SalonDetailState> emit,
  ) async {
    final salon = state.salon;
    if (salon == null) return;

    emit(state.copyWith(
      salon: salon.copyWith(isFollowing: !salon.isFollowing),
    ));

    try {
      final followed = await _discovery.toggleFollow(
        type: salon.type,
        id: salon.id,
      );

      emit(state.copyWith(salon: salon.copyWith(isFollowing: followed)));
    } on ApiException catch (e) {
      emit(state.copyWith(salon: salon, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        salon: salon,
        errorMessage: 'Could not update follow.',
      ));
    }
  }
}
