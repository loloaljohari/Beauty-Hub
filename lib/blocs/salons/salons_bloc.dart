import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/salon_model.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../data/repositories/salons_repository.dart';
import 'salons_event.dart';
import 'salons_state.dart';

class SalonsBloc extends Bloc<SalonsEvent, SalonsState> {
  SalonsBloc({
    SalonsRepository? repository,
    DiscoveryRepository? discovery,
  })  : _repository = repository ?? const SalonsRepository(),
        _discovery = discovery ?? const DiscoveryRepository(),
        super(const SalonsState()) {
    on<SalonsLoaded>(_onLoaded);
    on<SalonsTabChanged>(_onTabChanged);
    on<SalonsCityChanged>(_onCityChanged);
    on<SalonFollowRequested>(_onFollowRequested);
  }

  final SalonsRepository _repository;
  final DiscoveryRepository _discovery;

  /// Salons and centers are two separate calls because the endpoint
  /// takes a single `type`. Both are fetched up front so switching the
  /// tab is instant and the counts are right.
  Future<void> _onLoaded(SalonsLoaded event, Emitter<SalonsState> emit) async {
    emit(state.copyWith(status: SalonsStatus.loading, errorMessage: null));

    try {
      final salons = await _discovery.getProviders(
        type: SalonType.salon,
        city: state.selectedCity,
      );

      final centers = await _discovery.getProviders(
        type: SalonType.center,
        city: state.selectedCity,
      );

      emit(
        state.copyWith(
          allSalons: [...salons, ...centers],
          // The city chips stay local: there is no endpoint listing the
          // governorates in use, and this list is stable.
          cities: _repository.getCities(),
          status: SalonsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: SalonsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SalonsStatus.failure,
        errorMessage: 'Could not load salons and centers.',
      ));
    }
  }

  void _onTabChanged(SalonsTabChanged event, Emitter<SalonsState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  /// The city filter is applied server-side, so changing it refetches.
  void _onCityChanged(SalonsCityChanged event, Emitter<SalonsState> emit) {
    emit(state.copyWith(selectedCity: event.city));
    add(const SalonsLoaded());
  }

  Future<void> _onFollowRequested(
    SalonFollowRequested event,
    Emitter<SalonsState> emit,
  ) async {
    final target = state.allSalons
        .where((salon) => salon.id == event.salonId)
        .toList();

    if (target.isEmpty) return;

    final salon = target.first;

    // Optimistic flip so the button responds immediately; reverted
    // below if the server disagrees.
    emit(state.copyWith(
      allSalons: state.allSalons
          .map((s) => s.id == salon.id
              ? s.copyWith(isFollowing: !s.isFollowing)
              : s)
          .toList(),
    ));

    try {
      final followed = await _discovery.toggleFollow(
        type: salon.type,
        id: salon.id,
      );

      emit(state.copyWith(
        allSalons: state.allSalons
            .map((s) => s.id == salon.id ? s.copyWith(isFollowing: followed) : s)
            .toList(),
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        allSalons: state.allSalons
            .map((s) =>
                s.id == salon.id ? s.copyWith(isFollowing: salon.isFollowing) : s)
            .toList(),
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        allSalons: state.allSalons
            .map((s) =>
                s.id == salon.id ? s.copyWith(isFollowing: salon.isFollowing) : s)
            .toList(),
        errorMessage: 'Could not update follow.',
      ));
    }
  }
}
