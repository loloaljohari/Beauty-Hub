import 'package:equatable/equatable.dart';
import '../../data/models/course_model.dart';

enum MyCoursesStatus { initial, loading, loaded, failure }

class MyCoursesState extends Equatable {
  const MyCoursesState({
    this.courses = const [],
    this.status = MyCoursesStatus.initial,
    this.errorMessage,
  });

  final List<CourseModel> courses;
  final MyCoursesStatus status;
  final String? errorMessage;

  bool get isEmpty => status == MyCoursesStatus.loaded && courses.isEmpty;

  MyCoursesState copyWith({
    List<CourseModel>? courses,
    MyCoursesStatus? status,
    String? errorMessage,
  }) {
    return MyCoursesState(
      courses: courses ?? this.courses,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [courses, status, errorMessage];
}
