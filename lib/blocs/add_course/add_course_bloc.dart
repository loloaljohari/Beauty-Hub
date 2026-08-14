import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/training_repository.dart';
import 'add_course_event.dart';
import 'add_course_state.dart';

class AddCourseBloc extends Bloc<AddCourseEvent, AddCourseState> {
  AddCourseBloc({TrainingRepository? repository})
      : _repository = repository ?? const TrainingRepository(),
        super(const AddCourseState()) {
    on<AddCourseStarted>(_onStarted);
    on<AddCourseFieldChanged>(_onFieldChanged);
    on<AddCourseOnlineToggled>(_onOnlineToggled);
    on<AddCourseCoverPicked>(_onCoverPicked);
    on<AddCourseSubmitted>(_onSubmitted);
  }

  final TrainingRepository _repository;

  Future<void> _onStarted(
    AddCourseStarted event,
    Emitter<AddCourseState> emit,
  ) async {
    if (event.courseId == null) return;

    emit(state.copyWith(
      courseId: event.courseId,
      status: AddCourseStatus.loading,
    ));

    try {
      // There is no single-course GET wired for the form, so the
      // course is picked out of the list the expert already owns.
      final courses = await _repository.getManagedCourses();
      final match = courses.where((c) => c.id == event.courseId);

      if (match.isEmpty) {
        emit(state.copyWith(
          status: AddCourseStatus.failure,
          errorMessage: 'That course no longer exists.',
        ));
        return;
      }

      final course = match.first;

      emit(state.copyWith(
        fields: {
          'title': course.title,
          'price': course.price.toString(),
          'duration_hours': course.lessonsCount.toString(),
        },
        existingCoverUrl: course.imageUrl,
        status: AddCourseStatus.initial,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: 'Could not open this course.',
      ));
    }
  }

  void _onFieldChanged(
    AddCourseFieldChanged event,
    Emitter<AddCourseState> emit,
  ) {
    final fields = Map<String, String>.from(state.fields)
      ..[event.key] = event.value;

    // Clear the server error for a field as soon as it is edited.
    final errors = Map<String, String>.from(state.fieldErrors)
      ..remove(event.key);

    emit(state.copyWith(
      fields: fields,
      fieldErrors: errors,
      status: AddCourseStatus.initial,
    ));
  }

  void _onOnlineToggled(
    AddCourseOnlineToggled event,
    Emitter<AddCourseState> emit,
  ) {
    emit(state.copyWith(isOnline: event.isOnline));
  }

  void _onCoverPicked(
    AddCourseCoverPicked event,
    Emitter<AddCourseState> emit,
  ) {
    emit(state.copyWith(coverImagePath: event.imagePath));
  }

  Future<void> _onSubmitted(
    AddCourseSubmitted event,
    Emitter<AddCourseState> emit,
  ) async {
    // Mirrors StoreCourseRequest: title and price are the only two
    // required fields.
    final title = state.value('title').trim();
    final price = double.tryParse(state.value('price').trim());

    if (title.isEmpty) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: 'Give the course a title.',
      ));
      return;
    }

    if (price == null || price < 0) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: 'Enter a valid price (0 or more).',
      ));
      return;
    }

    final start = state.value('start_date');
    final end = state.value('end_date');

    // The server rule is `after_or_equal:start_date`.
    if (start.isNotEmpty && end.isNotEmpty) {
      final startDate = DateTime.tryParse(start);
      final endDate = DateTime.tryParse(end);
      if (startDate != null &&
          endDate != null &&
          endDate.isBefore(startDate)) {
        emit(state.copyWith(
          status: AddCourseStatus.failure,
          errorMessage: 'The end date cannot be before the start date.',
        ));
        return;
      }
    }

    emit(state.copyWith(status: AddCourseStatus.submitting));

    try {
      if (state.isEditing) {
        await _repository.updateCourse(
          courseId: state.courseId!,
          fields: {
            'title': title,
            'price': price.toString(),
            if (state.value('description').isNotEmpty)
              'description': state.value('description'),
            if (state.value('duration_hours').isNotEmpty)
              'duration_hours': state.value('duration_hours'),
            if (state.value('max_enrollments').isNotEmpty)
              'max_enrollments': state.value('max_enrollments'),
            if (start.isNotEmpty) 'start_date': start,
            if (end.isNotEmpty) 'end_date': end,
            'is_online': state.isOnline ? '1' : '0',
            if (state.value('location').isNotEmpty)
              'location': state.value('location'),
          },
          coverImagePath: state.coverImagePath,
        );
      } else {
        await _repository.createCourse(
          title: title,
          price: price,
          description: state.value('description'),
          durationHours: double.tryParse(state.value('duration_hours')),
          maxEnrollments: int.tryParse(state.value('max_enrollments')),
          startDate: start,
          endDate: end,
          isOnline: state.isOnline,
          location: state.value('location'),
          coverImagePath: state.coverImagePath,
        );
      }

      emit(state.copyWith(status: AddCourseStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: e.message,
        fieldErrors: e.errors,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddCourseStatus.failure,
        errorMessage: 'Could not save the course. Please try again.',
      ));
    }
  }
}
