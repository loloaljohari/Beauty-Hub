import 'package:equatable/equatable.dart';
import '../../data/models/job_request_model.dart';

enum JobDetailStatus { initial, loading, loaded, failure }

class JobDetailState extends Equatable {
  const JobDetailState( {this.job,this.errorMessage, this.status = JobDetailStatus.initial});

  final JobRequestModel? job;
  final JobDetailStatus status;
  final String? errorMessage;

  JobDetailState copyWith({
    JobRequestModel? job,
    JobDetailStatus? status,
    String? errorMessage,
  }) {
    return JobDetailState(
      job: job ?? this.job,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [job, status, errorMessage];
}
