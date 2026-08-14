import '../models/course_model.dart';
import 'training_repository.dart';

/// "My Courses" - the courses this expert publishes.
///
/// This used to return two hardcoded rows while [TrainingRepository]
/// already had `GET /expert/courses` wired, so the same data existed
/// twice in the app from two different sources. It now delegates to
/// that one implementation and maps into [CourseModel], which is the
/// shape this screen's widgets expect.
class CoursesRepository {
  const CoursesRepository({TrainingRepository? training})
      : _training = training ?? const TrainingRepository();

  final TrainingRepository _training;

  Future<List<CourseModel>> getCourses() async {
    final courses = await _training.getManagedCourses();

    return courses
        .map((course) => CourseModel(
              id: course.id,
              title: course.title,
              // The expert IS the provider of these courses, so the
              // enrollment count is what is actually worth showing in
              // that slot.
              provider: '${course.studentsCount} trainee(s)',
              year: course.publishedDate,
            ))
        .toList();
  }

  /// DELETE /expert/courses/{id}
  Future<void> deleteCourse(Object id) => _training.deleteCourse(id);
}
