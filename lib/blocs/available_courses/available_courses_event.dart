import 'package:equatable/equatable.dart';

abstract class AvailableCoursesEvent extends Equatable {
  const AvailableCoursesEvent();

  @override
  List<Object?> get props => [];
}

class AvailableCoursesLoaded extends AvailableCoursesEvent {
  const AvailableCoursesLoaded();
}

class CourseEnrollRequested extends AvailableCoursesEvent {
  const CourseEnrollRequested(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}
