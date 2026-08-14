import 'package:equatable/equatable.dart';

abstract class JobRequestsEvent extends Equatable {
  const JobRequestsEvent();

  @override
  List<Object?> get props => [];
}

class JobRequestsLoaded extends JobRequestsEvent {
  const JobRequestsLoaded();
}

class JobRequestAccepted extends JobRequestsEvent {
  const JobRequestAccepted(this.jobId);

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}

class JobRequestCancelled extends JobRequestsEvent {
  const JobRequestCancelled(this.jobId);

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}
