import 'package:equatable/equatable.dart';

abstract class MyManagedCoursesEvent extends Equatable {
  const MyManagedCoursesEvent();

  @override
  List<Object?> get props => [];
}

class MyManagedCoursesLoaded extends MyManagedCoursesEvent {
  const MyManagedCoursesLoaded();
}

class ManagedCourseDeleted extends MyManagedCoursesEvent {
  const ManagedCourseDeleted(this.courseId);

  final String courseId;

  @override
  List<Object?> get props => [courseId];
}
