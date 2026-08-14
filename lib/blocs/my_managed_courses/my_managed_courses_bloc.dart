import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/training_repository.dart';
import 'my_managed_courses_event.dart';
import 'my_managed_courses_state.dart';

class MyManagedCoursesBloc
    extends Bloc<MyManagedCoursesEvent, MyManagedCoursesState> {
  MyManagedCoursesBloc({TrainingRepository? repository})
      : _repository = repository ?? const TrainingRepository(),
        super(const MyManagedCoursesState()) {
    on<MyManagedCoursesLoaded>(_onLoaded);
    on<ManagedCourseDeleted>(_onDeleted);
  }

  final TrainingRepository _repository;

  Future<void> _onLoaded(
    MyManagedCoursesLoaded event,
    Emitter<MyManagedCoursesState> emit,
  ) async {
    emit(state.copyWith(
      status: MyManagedCoursesStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(
        state.copyWith(
          courses: await _repository.getManagedCourses(),
          status: MyManagedCoursesStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MyManagedCoursesStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: MyManagedCoursesStatus.failure,
        errorMessage: 'Could not load your courses.',
      ));
    }
  }

  Future<void> _onDeleted(
    ManagedCourseDeleted event,
    Emitter<MyManagedCoursesState> emit,
  ) async {
    final previous = state.courses;

    emit(state.copyWith(
      courses: previous.where((c) => c.id != event.courseId).toList(),
    ));

    try {
      await _repository.deleteCourse(event.courseId);
    } on ApiException catch (e) {
      // A course with enrollments cannot be deleted server-side; put
      // the row back rather than leaving the list lying to the user.
      emit(state.copyWith(courses: previous, errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        courses: previous,
        errorMessage: 'Could not delete this course.',
      ));
    }
  }
}
