import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/training_models.dart';
import '../../data/repositories/training_repository.dart';
import 'enrollments_event.dart';
import 'enrollments_state.dart';

class EnrollmentsBloc extends Bloc<EnrollmentsEvent, EnrollmentsState> {
  EnrollmentsBloc({TrainingRepository? repository})
      : _repository = repository ?? const TrainingRepository(),
        super(const EnrollmentsState()) {
    on<EnrollmentsLoaded>(_onLoaded);
    on<EnrollmentsTabChanged>(_onTabChanged);
    on<EnrollmentProgressUpdated>(_onProgressUpdated);
    on<EnrollmentCertificateIssued>(_onCertificateIssued);
  }

  final TrainingRepository _repository;

  /// Trainees enrolled on the expert's courses.
  ///
  /// The backend scopes enrollments to a single course
  /// (`GET /expert/courses/{id}/enrollments`), so with no course id the
  /// BLoC fans out across the expert's courses and merges the results -
  /// there is no "all my enrollments" endpoint to call instead.
  Future<void> _onLoaded(
    EnrollmentsLoaded event,
    Emitter<EnrollmentsState> emit,
  ) async {
    emit(state.copyWith(
      status: EnrollmentsStatus.loading,
      errorMessage: null,
    ));

    try {
      if (event.courseId != null) {
        emit(state.copyWith(
          allEnrollments:
              await _repository.getCourseEnrollments(event.courseId!),
          courseId: event.courseId,
          status: EnrollmentsStatus.loaded,
        ));
        return;
      }

      final courses = await _repository.getManagedCourses();

      final all = <EnrollmentModel>[];
      final owners = <String, String>{};

      for (final course in courses) {
        final rows = await _repository.getCourseEnrollments(course.id);
        for (final row in rows) {
          owners[row.id] = course.id;
        }
        all.addAll(rows);
      }

      emit(state.copyWith(
        allEnrollments: all,
        courseIdByEnrollment: owners,
        status: EnrollmentsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: EnrollmentsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: EnrollmentsStatus.failure,
        errorMessage: 'Could not load enrollments.',
      ));
    }
  }

  void _onTabChanged(
    EnrollmentsTabChanged event,
    Emitter<EnrollmentsState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  Future<void> _onProgressUpdated(
    EnrollmentProgressUpdated event,
    Emitter<EnrollmentsState> emit,
  ) async {
    final courseId = event.courseId ??
        state.courseIdByEnrollment[event.enrollmentId] ??
        state.courseId;

    if (courseId == null) return;

    try {
      await _repository.updateEnrollmentProgress(
        courseId: courseId,
        enrollmentId: event.enrollmentId,
        progressPercent: event.progressPercent,
      );
      add(EnrollmentsLoaded(courseId: state.courseId));
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not update progress.'));
    }
  }

  /// Reaching 100% completes an enrollment but does not issue the
  /// certificate; the expert grants it explicitly through this action.
  Future<void> _onCertificateIssued(
    EnrollmentCertificateIssued event,
    Emitter<EnrollmentsState> emit,
  ) async {
    final courseId = event.courseId ??
        state.courseIdByEnrollment[event.enrollmentId] ??
        state.courseId;

    if (courseId == null) return;

    try {
      await _repository.issueCertificate(
        courseId: courseId,
        enrollmentId: event.enrollmentId,
      );
      add(EnrollmentsLoaded(courseId: state.courseId));
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(
        errorMessage: 'Could not issue the certificate.',
      ));
    }
  }
}
