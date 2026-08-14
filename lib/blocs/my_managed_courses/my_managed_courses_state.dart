import 'package:equatable/equatable.dart';
import '../../data/models/training_models.dart';

enum MyManagedCoursesStatus { initial, loading, loaded, failure }

class MyManagedCoursesState extends Equatable {
  const MyManagedCoursesState({
    this.courses = const [],
    this.status = MyManagedCoursesStatus.initial,
    this.errorMessage,
  });

  final List<ManagedCourseModel> courses;
  final MyManagedCoursesStatus status;
  final String? errorMessage;

  bool get isEmpty =>
      status == MyManagedCoursesStatus.loaded && courses.isEmpty;

  MyManagedCoursesState copyWith({
    List<ManagedCourseModel>? courses,
    MyManagedCoursesStatus? status,
    String? errorMessage,
  }) {
    return MyManagedCoursesState(
      courses: courses ?? this.courses,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [courses, status, errorMessage];
}
