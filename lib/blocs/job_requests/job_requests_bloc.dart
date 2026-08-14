import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/job_request_model.dart';
import '../../data/repositories/job_requests_repository.dart';
import 'job_requests_event.dart';
import 'job_requests_state.dart';

class JobRequestsBloc extends Bloc<JobRequestsEvent, JobRequestsState> {
  JobRequestsBloc({JobRequestsRepository? repository})
      : _repository = repository ?? const JobRequestsRepository(),
        super(const JobRequestsState()) {
    on<JobRequestsLoaded>(_onLoaded);
    on<JobRequestAccepted>(_onAccepted);
    on<JobRequestCancelled>(_onCancelled);
  }

  final JobRequestsRepository _repository;

  Future<void> _onLoaded(
    JobRequestsLoaded event,
    Emitter<JobRequestsState> emit,
  ) async {
    emit(state.copyWith(
      status: JobRequestsStatus.loading,
      errorMessage: null,
    ));

    try {
      final requests = await _repository.getJobRequests();

      // The API returns the full list with a status on each row; the
      // three header counters are derived from it rather than fetched
      // separately (there is no counts endpoint).
      emit(
        state.copyWith(
          requests: requests,
          newCount: requests
              .where((r) => r.status == JobRequestStatus.newRequest)
              .length,
          acceptedCount: requests
              .where((r) => r.status == JobRequestStatus.accepted)
              .length,
          rejectedCount: requests
              .where((r) => r.status == JobRequestStatus.rejected)
              .length,
          status: JobRequestsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JobRequestsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JobRequestsStatus.failure,
        errorMessage: 'Could not load your job requests.',
      ));
    }
  }

  Future<void> _onAccepted(
    JobRequestAccepted event,
    Emitter<JobRequestsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: JobRequestActionStatus.loading));

    try {
      await _repository.acceptRequest(event.jobId);
      emit(state.copyWith(actionStatus: JobRequestActionStatus.success));
      // Accepting also enrolls the expert on the provider's roster
      // server-side, so a refetch is the only way to stay truthful.
      add(const JobRequestsLoaded());
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: JobRequestActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: JobRequestActionStatus.failure,
        errorMessage: 'Could not accept this request.',
      ));
    }
  }

  /// "Cancel" on this screen means declining the offer, which maps to
  /// the backend's reject endpoint.
  Future<void> _onCancelled(
    JobRequestCancelled event,
    Emitter<JobRequestsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: JobRequestActionStatus.loading));

    try {
      await _repository.rejectRequest(event.jobId);
      emit(state.copyWith(actionStatus: JobRequestActionStatus.success));
      add(const JobRequestsLoaded());
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: JobRequestActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: JobRequestActionStatus.failure,
        errorMessage: 'Could not decline this request.',
      ));
    }
  }
}
