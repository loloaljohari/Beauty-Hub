import 'package:equatable/equatable.dart';

/// A course the expert created and teaches themselves, shown on
/// "My Courses" under Training & Courses (NOT the same as the
/// simpler enrolled-courses list on the Profile screen).
class ManagedCourseModel extends Equatable {
  const ManagedCourseModel({
    required this.id,
    required this.title,
    required this.publishedDate,
    required this.studentsCount,
    required this.lessonsCount,
    required this.price,
    this.isPublished = true,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String publishedDate;
  final int studentsCount;
  final int lessonsCount;
  final double price;
  final bool isPublished;
  final String? imageUrl;

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        title,
        publishedDate,
        studentsCount,
        lessonsCount,
        price,
        isPublished,
        imageUrl,
      ];
}

/// A course offered by another salon/center/academy, browsable and
/// enrollable from "Available Courses".
class AvailableCourseModel extends Equatable {
  const AvailableCourseModel({
    required this.id,
    required this.title,
    required this.providerName,
    required this.studentsCount,
    required this.lessonsCount,
    required this.startDate,
    required this.price,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String providerName;
  final int studentsCount;
  final int lessonsCount;
  final String startDate;
  final double price;
  final String? imageUrl;

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        title,
        providerName,
        studentsCount,
        lessonsCount,
        startDate,
        price,
        imageUrl,
      ];
}

enum EnrollmentStatus { inProgress, completed, canceled }

/// A course the expert has enrolled in elsewhere, with progress
/// tracking, shown on "My Enrollments".
class EnrollmentModel extends Equatable {
  const EnrollmentModel({
    required this.id,
    required this.title,
    required this.providerName,
    required this.progressPercent,
    required this.completedLessons,
    required this.totalLessons,
    this.status = EnrollmentStatus.inProgress,
    this.imageUrl,
    this.certificateIssued = false,
  });

  final String id;
  final String title;
  final String providerName;
  final int progressPercent;
  final int completedLessons;
  final int totalLessons;
  final EnrollmentStatus status;
  final String? imageUrl;

  /// Whether the expert has already granted this trainee a certificate.
  /// Completing a course does not issue one automatically.
  final bool certificateIssued;

  @override
  List<Object?> get props => [
        id,
        title,
        providerName,
        progressPercent,
        completedLessons,
        totalLessons,
        status,
        imageUrl,
        certificateIssued,
      ];
}

/// Origin of a certificate, used to filter the "My Certificates"
/// tabs (All / Created by me / from Salon & Center).
enum CertificateOrigin { createdByMe, fromSalonOrCenter }

/// A completion certificate shown on "My Certificates".
class CertificateModel extends Equatable {
  const CertificateModel({
    required this.id,
    required this.title,
    required this.providerName,
    required this.year,
    required this.origin,
    this.certificateNumber,
    this.documentUrl,
    this.isVerified = false,
  });

  final String id;
  final String title;
  final String providerName;
  final String year;
  final CertificateOrigin origin;

  /// Only set for course certificates the expert granted.
  final String? certificateNumber;

  /// Downloadable PDF/image, already absolute.
  final String? documentUrl;

  /// Profile credentials only - verification is a Super Admin action.
  final bool isVerified;

  @override
  List<Object?> get props => [
        id,
        title,
        providerName,
        year,
        origin,
        certificateNumber,
        documentUrl,
        isVerified,
      ];
}
