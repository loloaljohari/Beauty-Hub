import 'package:equatable/equatable.dart';

abstract class MyCoursesEvent extends Equatable {
  const MyCoursesEvent();

  @override
  List<Object?> get props => [];
}

class MyCoursesLoaded extends MyCoursesEvent {
  const MyCoursesLoaded();
}

class MyCourseDeleted extends MyCoursesEvent {
  const MyCourseDeleted(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}
