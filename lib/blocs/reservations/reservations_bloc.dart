import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../data/repositories/reservations_repository.dart';
import 'reservations_event.dart';
import 'reservations_state.dart';

class ReservationsBloc extends Bloc<ReservationsEvent, ReservationsState> {
  ReservationsBloc({ReservationsRepository? repository})
      : _repository = repository ?? const ReservationsRepository(),
        super(const ReservationsState()) {
    on<ReservationsLoaded>(_onLoaded);
    on<ReservationsTabChanged>(_onTabChanged);
    on<ReservationCancelled>(_onCancelled);
    on<ReservationConfirmed>(_onConfirmed);
    on<ReservationCompleted>(_onCompleted);
    on<GetBookingDetails>(_onGetDetails);
  }

  final ReservationsRepository _repository;

  Future<void> _onLoaded(
    ReservationsLoaded event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(
      status: ReservationsStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(
        state.copyWith(
          bookings: await _repository.getBookings(),
          tabIndex: await StorageService.getLastReservationsTab(),
          status: ReservationsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ReservationsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ReservationsStatus.failure,
        errorMessage: 'Could not load your bookings.',
      ));
    }
  }

  void _onTabChanged(
    ReservationsTabChanged event,
    Emitter<ReservationsState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
    StorageService.saveLastReservationsTab(event.tabIndex);
  }

  /// Previously built its own `http.Request` with a Bearer token pasted
  /// into the source. That token belonged to one developer's session
  /// and would 401 for every other user - it is gone, and the call now
  /// runs through the repository like every other request.
  Future<void> _onGetDetails(
    GetBookingDetails event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(
      detailStatus: ReservationsStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(state.copyWith(
        selectedBooking: await _repository.getBookingDetails(event.bookingId),
        detailStatus: ReservationsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        detailStatus: ReservationsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        detailStatus: ReservationsStatus.failure,
        errorMessage: 'Could not load this booking.',
      ));
    }
  }

  /// Approve: pending -> confirmed, and the customer gets a push.
  Future<void> _onConfirmed(
    ReservationConfirmed event,
    Emitter<ReservationsState> emit,
  ) async {
    await _changeStatus(
      emit,
      () => _repository.confirmBooking(event.bookingId),
      event.bookingId,
      'Could not approve this booking.',
    );
  }

  /// Complete: confirmed -> completed.
  Future<void> _onCompleted(
    ReservationCompleted event,
    Emitter<ReservationsState> emit,
  ) async {
    await _changeStatus(
      emit,
      () => _repository.completeBooking(event.bookingId),
      event.bookingId,
      'Could not complete this booking.',
    );
  }

  /// Shared path for both transitions.
  ///
  /// The detail screen is refetched rather than patched locally, so the
  /// buttons follow the status the SERVER now holds - it rejects
  /// invalid transitions, and guessing here would show the wrong pair.
  Future<void> _changeStatus(
    Emitter<ReservationsState> emit,
    Future<void> Function() action,
    String bookingId,
    String fallbackMessage,
  ) async {
    emit(state.copyWith(actionStatus: ReservationActionStatus.loading));

    try {
      await action();

      emit(state.copyWith(
        selectedBooking: await _repository.getBookingDetails(bookingId),
        bookings: await _repository.getBookings(),
        actionStatus: ReservationActionStatus.success,
        errorMessage: "success"
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ReservationActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: ReservationActionStatus.failure,
        errorMessage: fallbackMessage,
      ));
    }
  }

  Future<void> _onCancelled(
    ReservationCancelled event,
    Emitter<ReservationsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: ReservationActionStatus.loading));

    try {
      await _repository.deleteBooking(event.bookingId, event.reason);

      emit(state.copyWith(
        bookings: await _repository.getBookings(),
        status: ReservationsStatus.loaded,
        actionStatus: ReservationActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ReservationActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: ReservationActionStatus.failure,
        errorMessage: 'Could not cancel this booking.',
      ));
    }
  }
}