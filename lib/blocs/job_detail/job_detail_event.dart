import 'package:equatable/equatable.dart';

abstract class JobDetailEvent extends Equatable {
  const JobDetailEvent();

  @override
  List<Object?> get props => [];
}

class JobDetailLoaded extends JobDetailEvent {
  const JobDetailLoaded(this.jobId);

  final String jobId;

  @override
  List<Object?> get props => [jobId];
}
