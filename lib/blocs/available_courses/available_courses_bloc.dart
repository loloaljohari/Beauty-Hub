import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/discovery_repository.dart';
import '../../data/repositories/training_repository.dart';
import 'available_courses_event.dart';
import 'available_courses_state.dart';

class AvailableCoursesBloc
    extends Bloc<AvailableCoursesEvent, AvailableCoursesState> {
  AvailableCoursesBloc({TrainingRepository? repository})
      : _repository = repository ?? const TrainingRepository(),
        super(const AvailableCoursesState()) {
    on<AvailableCoursesLoaded>(_onLoaded);
    on<CourseEnrollRequested>(_onEnrollRequested);
  }

  final TrainingRepository _repository;

  /// GET /expert/discover/courses - courses published by everyone
  /// except this expert.
  ///
  /// Browsing only. Enrolling is a customer action
  /// (`POST /customer/courses/{id}/enroll`) with no expert-side route,
  /// so the enrol button stays local until the backend grows one.
  Future<void> _onLoaded(
    AvailableCoursesLoaded event,
    Emitter<AvailableCoursesState> emit,
  ) async {
    emit(state.copyWith(status: AvailableCoursesStatus.loading));

    try {
      final catalogue = await const DiscoveryRepository()
          .getAvailableCoursesWithEnrolment();

      emit(
        state.copyWith(
          courses: catalogue.courses,
          // Comes from the API, so a course enrolled in on another
          // device already reads as "Enrolled" here.
          enrolledIds: catalogue.enrolledIds,
          status: AvailableCoursesStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AvailableCoursesStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AvailableCoursesStatus.failure,
        errorMessage: 'Could not load available courses.',
      ));
    }
  }

  /// POST /expert/discover/courses/{id}/enroll
  ///
  /// This only added the id to a local list before, so "Enrol now"
  /// looked like it worked and nothing was recorded.
  Future<void> _onEnrollRequested(
    CourseEnrollRequested event,
    Emitter<AvailableCoursesState> emit,
  ) async {
    if (state.enrolledIds.contains(event.courseId)) return;

    // Optimistic: the button flips immediately and is reverted below if
    // the server refuses (full course, already enrolled, own course).
    emit(state.copyWith(
      enrolledIds: [...state.enrolledIds, event.courseId],
      errorMessage: null,
    ));

    try {
      await const DiscoveryRepository().enrollInCourse(event.courseId);
    } on ApiException catch (e) {
      emit(state.copyWith(
        enrolledIds:
            state.enrolledIds.where((id) => id != event.courseId).toList(),
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        enrolledIds:
            state.enrolledIds.where((id) => id != event.courseId).toList(),
        errorMessage: 'Could not enrol in this course.',
      ));
    }
  }
}
