import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/training_models.dart';

/// Training & Courses, backed by `GET /expert/courses` and friends.
///
/// Scope note - the expert is a *provider* of courses in this backend,
/// not a trainee:
///   * "My Courses"        -> real: `GET /expert/courses`.
///   * "My Certificates"   -> real: `GET /expert/certificates`, i.e.
///     certificates this expert has GRANTED to trainees. There is no
///     endpoint returning certificates the expert has EARNED, so the
///     `createdByMe` / `fromSalonOrCenter` split is now driven by that
///     reality rather than invented.
///   * "Available Courses" -> the browse-and-enroll catalogue lives on
///     the customer role (`GET /customer/courses`) and is not reachable
///     with an expert token. Left unimplemented on purpose.
///   * "My Enrollments"    -> same reason; the expert-side
///     `courses/{id}/enrollments` lists TRAINEES on the expert's own
///     course, which is a different screen. Exposed as
///     [getCourseEnrollments] for that purpose.
class TrainingRepository {
  const TrainingRepository();

  /// GET /expert/courses -> {courses: [...], total, nextPageUrl}
  Future<List<ManagedCourseModel>> getManagedCourses({
    String? query,
    bool? isActive,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.courses,
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (isActive != null) 'is_active': isActive ? 1 : 0,
      },
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['courses'])
        .map(_toManagedCourse)
        .toList();
  }

  /// POST /expert/courses (multipart - it accepts a cover image).
  Future<void> createCourse({
    required String title,
    required double price,
    String? description,
    int? categoryId,
    double? durationHours,
    int? maxEnrollments,
    String? startDate,
    String? endDate,
    bool isOnline = false,
    String? location,
    String? coverImagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.courses,
      fields: {
        'title': title,
        'price': price.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (durationHours != null) 'duration_hours': durationHours.toString(),
        if (maxEnrollments != null)
          'max_enrollments': maxEnrollments.toString(),
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
        'is_online': isOnline ? '1' : '0',
        if (location != null && location.isNotEmpty) 'location': location,
      },
      files: {
        if (coverImagePath != null && coverImagePath.isNotEmpty)
          'cover_image': coverImagePath,
      },
    );
  }

  /// POST /expert/courses/{id} - the backend registers this as
  /// `match(['put','post'])` precisely so a multipart cover can be sent.
  Future<void> updateCourse({
    required Object courseId,
    Map<String, String> fields = const {},
    String? coverImagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.course(courseId),
      fields: fields,
      files: {
        if (coverImagePath != null && coverImagePath.isNotEmpty)
          'cover_image': coverImagePath,
      },
    );
  }

  Future<void> deleteCourse(Object courseId) async {
    await ApiClient.delete(ApiEndpoints.course(courseId));
  }

  /// POST /expert/courses/{id}/archive - soft-hides it from trainees.
  Future<void> archiveCourse(Object courseId) async {
    await ApiClient.post(ApiEndpoints.archiveCourse(courseId));
  }

  /// GET /expert/courses/{id}/enrollments - trainees on one course.
  Future<List<EnrollmentModel>> getCourseEnrollments(
    Object courseId, {
    bool? completedOnly,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.courseEnrollments(courseId),
      query: {if (completedOnly != null) 'completed': completedOnly ? 1 : 0},
    );

    final payload = ApiResponse.data(response);
    final course = ApiResponse.asMap(payload['course']);
    final courseTitle = ApiResponse.asString(course['title']);

    return ApiResponse.asMapList(payload['enrollments'])
        .map((row) => _toEnrollment(row, courseTitle))
        .toList();
  }

  /// PUT /expert/courses/{c}/enrollments/{e}/progress
  ///
  /// Reaching 100 completes the enrollment but deliberately does NOT
  /// issue the certificate - that is a separate, explicit action.
  Future<void> updateEnrollmentProgress({
    required Object courseId,
    required Object enrollmentId,
    required int progressPercent,
  }) async {
    await ApiClient.put(
      ApiEndpoints.enrollmentProgress(courseId, enrollmentId),
      body: {'progress_percent': progressPercent},
    );
  }

  /// POST /expert/courses/{c}/enrollments/{e}/certificate
  Future<void> issueCertificate({
    required Object courseId,
    required Object enrollmentId,
  }) async {
    await ApiClient.post(
      ApiEndpoints.issueCertificate(courseId, enrollmentId),
    );
  }

  /// GET /expert/certificates - certificates this expert has granted.
  Future<List<CertificateModel>> getCertificates({Object? courseId}) async {
    final response = await ApiClient.get(
      ApiEndpoints.grantedCertificates,
      query: {if (courseId != null) 'course_id': courseId},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['certificates'])
        .map((row) => CertificateModel(
              id: ApiResponse.asString(row['certificate_id']),
              title: ApiResponse.asString(row['course_title']),
              // Who it was granted TO - the most useful thing to show
              // on a card listing certificates the expert issued.
              providerName: ApiResponse.asString(row['enrollee_name']),
              year: _yearOf(ApiResponse.asDate(row['issued_at'])),
              origin: CertificateOrigin.createdByMe,
              certificateNumber:
                  ApiResponse.asStringOrNull(row['certificate_number']),
              documentUrl:
                  AppConfig.mediaUrl(ApiResponse.asStringOrNull(row['pdf_path'])),
            ))
        .toList();
  }

  /// GET /expert/certificates-profile - the expert's OWN professional
  /// credentials (a different table from course certificates).
  Future<List<CertificateModel>> getProfileCertificates() async {
    final response = await ApiClient.get(ApiEndpoints.profileCertificates);

    return ApiResponse.asMapList(ApiResponse.data(response)['certificates'])
        .map((row) => CertificateModel(
              id: ApiResponse.asString(row['id']),
              title: ApiResponse.asString(row['title']),
              providerName: ApiResponse.asString(row['issuing_authority']),
              year: _yearOf(ApiResponse.asDate(row['issue_date'])),
              origin: CertificateOrigin.fromSalonOrCenter,
              isVerified: ApiResponse.asBool(row['is_verified']),
              documentUrl: ApiResponse.asStringOrNull(row['document_url']),
            ))
        .toList();
  }

  /// POST /expert/certificates-profile (multipart, `document` required).
  Future<void> addProfileCertificate({
    required String title,
    required String documentPath,
    String? issuingAuthority,
    String? issueDate,
    String? expiryDate,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.profileCertificates,
      fields: {
        'title': title,
        if (issuingAuthority != null && issuingAuthority.isNotEmpty)
          'issuing_authority': issuingAuthority,
        if (issueDate != null && issueDate.isNotEmpty) 'issue_date': issueDate,
        if (expiryDate != null && expiryDate.isNotEmpty)
          'expiry_date': expiryDate,
      },
      files: {'document': documentPath},
    );
  }

  Future<void> deleteProfileCertificate(Object id) async {
    await ApiClient.delete(ApiEndpoints.profileCertificate(id));
  }

  // ── mapping ─────────────────────────────────────────────────────

  ManagedCourseModel _toManagedCourse(Map<String, dynamic> row) {
    return ManagedCourseModel(
      id: ApiResponse.asString(row['id']),
      title: ApiResponse.asString(row['title']),
      publishedDate: ApiResponse.asDate(row['created_at']),
      studentsCount: ApiResponse.asInt(row['current_enrollments']),
      // There is no lessons table; duration in hours is the real
      // equivalent the API exposes.
      lessonsCount: ApiResponse.asDouble(row['duration_hours']).round(),
      price: ApiResponse.asDouble(row['price']),
      isPublished: ApiResponse.asBool(row['is_active'], fallback: true),
      imageUrl: ApiResponse.asStringOrNull(row['cover_image_url']) ??
          AppConfig.mediaUrl(ApiResponse.asStringOrNull(row['cover_image'])),
    );
  }

  EnrollmentModel _toEnrollment(Map<String, dynamic> row, String courseTitle) {
    final progress = ApiResponse.asInt(row['progress_percent']);
    final completed = ApiResponse.asStringOrNull(row['completed_at']) != null;

    return EnrollmentModel(
      id: ApiResponse.asString(row['enrollment_id']),
      title: courseTitle,
      // On this screen the "provider" slot shows the trainee, since
      // the expert is the one running the course.
      providerName: ApiResponse.asString(row['name']),
      progressPercent: progress,
      completedLessons: progress,
      totalLessons: 100,
      status: completed
          ? EnrollmentStatus.completed
          : EnrollmentStatus.inProgress,
      certificateIssued: ApiResponse.asBool(row['certificate_issued']),
    );
  }

  String _yearOf(String date) =>
      date.length >= 4 ? date.substring(0, 4) : date;
}
