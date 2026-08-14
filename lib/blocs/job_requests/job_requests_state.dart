import 'package:equatable/equatable.dart';
import '../../data/models/job_request_model.dart';

enum JobRequestsStatus { initial, loading, loaded, failure }

enum JobRequestActionStatus { initial, loading, success, failure }

class JobRequestsState extends Equatable {
  const JobRequestsState({
    this.requests = const [],
    this.newCount = 0,
    this.rejectedCount = 0,
    this.acceptedCount = 0,
    this.status = JobRequestsStatus.initial,
    this.actionStatus = JobRequestActionStatus.initial,
    this.errorMessage,
  });

  final List<JobRequestModel> requests;
  final int newCount;
  final int rejectedCount;
  final int acceptedCount;
  final JobRequestsStatus status;
  final JobRequestActionStatus actionStatus;
  final String? errorMessage;

  bool get isEmpty =>
      status == JobRequestsStatus.loaded && requests.isEmpty;

  JobRequestsState copyWith({
    List<JobRequestModel>? requests,
    int? newCount,
    int? rejectedCount,
    int? acceptedCount,
    JobRequestsStatus? status,
    JobRequestActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return JobRequestsState(
      requests: requests ?? this.requests,
      newCount: newCount ?? this.newCount,
      rejectedCount: rejectedCount ?? this.rejectedCount,
      acceptedCount: acceptedCount ?? this.acceptedCount,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [requests, newCount, rejectedCount, acceptedCount, status,
       actionStatus, errorMessage];
}
