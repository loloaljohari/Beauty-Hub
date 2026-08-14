import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/courses_repository.dart';
import 'my_courses_event.dart';
import 'my_courses_state.dart';

class MyCoursesBloc extends Bloc<MyCoursesEvent, MyCoursesState> {
  MyCoursesBloc({CoursesRepository? repository})
      : _repository = repository ?? const CoursesRepository(),
        super(const MyCoursesState()) {
    on<MyCoursesLoaded>(_onLoaded);
    on<MyCourseDeleted>(_onDeleted);
  }

  final CoursesRepository _repository;

  Future<void> _onLoaded(
    MyCoursesLoaded event,
    Emitter<MyCoursesState> emit,
  ) async {
    emit(state.copyWith(
      status: MyCoursesStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(state.copyWith(
        courses: await _repository.getCourses(),
        status: MyCoursesStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MyCoursesStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: MyCoursesStatus.failure,
        errorMessage: 'Could not load your courses.',
      ));
    }
  }

  /// Removing a course now actually deletes it server-side. Previously
  /// this only dropped the row from the in-memory list, so it came back
  /// on the next open.
  Future<void> _onDeleted(
    MyCourseDeleted event,
    Emitter<MyCoursesState> emit,
  ) async {
    final previous = state.courses;

    emit(state.copyWith(
      courses: previous.where((c) => c.id != event.courseId).toList(),
    ));

    try {
      await _repository.deleteCourse(event.courseId);
    } on ApiException catch (e) {
      // A course with enrollments cannot be deleted; restore the row
      // rather than leaving the list lying to the user.
      emit(state.copyWith(courses: previous, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        courses: previous,
        errorMessage: 'Could not delete this course.',
      ));
    }
  }
}
