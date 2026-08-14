import 'package:equatable/equatable.dart';

abstract class EnrollmentsEvent extends Equatable {
  const EnrollmentsEvent();

  @override
  List<Object?> get props => [];
}

/// With no [courseId] the BLoC loads enrollments across every course
/// the expert runs; with one it loads just that course's trainees.
class EnrollmentsLoaded extends EnrollmentsEvent {
  const EnrollmentsLoaded({this.courseId});

  final String? courseId;

  @override
  List<Object?> get props => [courseId];
}

/// Switches between In Progress / Completed / Canceled tabs.
class EnrollmentsTabChanged extends EnrollmentsEvent {
  const EnrollmentsTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class EnrollmentProgressUpdated extends EnrollmentsEvent {
  const EnrollmentProgressUpdated({
    required this.enrollmentId,
    required this.progressPercent,
    this.courseId,
  });

  final String enrollmentId;
  final int progressPercent;
  final String? courseId;

  @override
  List<Object?> get props => [enrollmentId, progressPercent, courseId];
}

class EnrollmentCertificateIssued extends EnrollmentsEvent {
  const EnrollmentCertificateIssued({
    required this.enrollmentId,
    this.courseId,
  });

  final String enrollmentId;
  final String? courseId;

  @override
  List<Object?> get props => [enrollmentId, courseId];
}
