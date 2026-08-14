import 'package:equatable/equatable.dart';
import '../../data/models/training_models.dart';

enum AvailableCoursesStatus { initial, loading, loaded, failure }

class AvailableCoursesState extends Equatable {
  const AvailableCoursesState({
    this.courses = const [],
    this.enrolledIds = const [],
    this.status = AvailableCoursesStatus.initial,
    this.errorMessage,
  });

  final List<AvailableCourseModel> courses;
  final List<String> enrolledIds;
  final AvailableCoursesStatus status;
  final String? errorMessage;

  bool get isEmpty =>
      status == AvailableCoursesStatus.loaded && courses.isEmpty;

  AvailableCoursesState copyWith({
    List<AvailableCourseModel>? courses,
    List<String>? enrolledIds,
    AvailableCoursesStatus? status,
    String? errorMessage,
  }) {
    return AvailableCoursesState(
      courses: courses ?? this.courses,
      enrolledIds: enrolledIds ?? this.enrolledIds,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [courses, enrolledIds, status, errorMessage];
}
