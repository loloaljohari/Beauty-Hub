import 'package:equatable/equatable.dart';
import '../../data/models/training_models.dart';

enum EnrollmentsStatus { initial, loading, loaded, failure }

class EnrollmentsState extends Equatable {
  const EnrollmentsState({
    this.allEnrollments = const [],
    this.tabIndex = 0,
    this.status = EnrollmentsStatus.initial,
    this.errorMessage,
    this.courseId,
    this.courseIdByEnrollment = const {},
  });

  final List<EnrollmentModel> allEnrollments;

  /// 0 = In Progress, 1 = Completed, 2 = Canceled.
  final int tabIndex;
  final EnrollmentsStatus status;
  final String? errorMessage;

  /// Set when the screen is scoped to a single course.
  final String? courseId;

  /// enrollmentId -> courseId, needed because progress and certificate
  /// endpoints are nested under the course, not the enrollment.
  final Map<String, String> courseIdByEnrollment;

  bool get isEmpty =>
      status == EnrollmentsStatus.loaded && allEnrollments.isEmpty;

  List<EnrollmentModel> get filteredEnrollments {
    final statusFilter = switch (tabIndex) {
      0 => EnrollmentStatus.inProgress,
      1 => EnrollmentStatus.completed,
      _ => EnrollmentStatus.canceled,
    };
    return allEnrollments.where((e) => e.status == statusFilter).toList();
  }

  EnrollmentsState copyWith({
    List<EnrollmentModel>? allEnrollments,
    int? tabIndex,
    EnrollmentsStatus? status,
    String? errorMessage,
    String? courseId,
    Map<String, String>? courseIdByEnrollment,
  }) {
    return EnrollmentsState(
      allEnrollments: allEnrollments ?? this.allEnrollments,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
      courseId: courseId ?? this.courseId,
      courseIdByEnrollment:
          courseIdByEnrollment ?? this.courseIdByEnrollment,
    );
  }

  @override
  List<Object?> get props => [allEnrollments, tabIndex, status, errorMessage,
        courseId, courseIdByEnrollment];
}
