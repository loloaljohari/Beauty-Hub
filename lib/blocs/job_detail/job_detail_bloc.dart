import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/job_request_model.dart';
import '../../data/repositories/job_requests_repository.dart';
import 'job_detail_event.dart';
import 'job_detail_state.dart';

class JobDetailBloc extends Bloc<JobDetailEvent, JobDetailState> {
  JobDetailBloc({JobRequestsRepository? repository})
      : _repository = repository ?? const JobRequestsRepository(),
        super(const JobDetailState()) {
    on<JobDetailLoaded>(_onLoaded);
  }

  final JobRequestsRepository _repository;

  Future<void> _onLoaded(
    JobDetailLoaded event,
    Emitter<JobDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: JobDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      final jobs = await _repository.getJobRequests();

      JobRequestModel? job;
      for (final j in jobs) {
        if (j.id == event.jobId) {
          job = j;
          break;
        }
      }

      if (job == null) {
        // Falling back to the first row (as this used to) would show
        // the details of somebody else's offer, which is worse than
        // admitting the request is gone.
        emit(state.copyWith(
          status: JobDetailStatus.failure,
          errorMessage: 'This request is no longer available.',
        ));
        return;
      }

      emit(state.copyWith(job: job, status: JobDetailStatus.loaded));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: JobDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: JobDetailStatus.failure,
        errorMessage: 'Could not load this request.',
      ));
    }
  }
}
