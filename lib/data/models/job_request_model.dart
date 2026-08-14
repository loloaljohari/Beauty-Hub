import 'package:equatable/equatable.dart';

enum JobRequestStatus { newRequest, accepted, rejected }

/// A job application/request shown on the "Job Requests" screen,
/// with full detail available via [JobRequestDetailModel] for the
/// bottom-sheet detail view.
class JobRequestModel extends Equatable {
  const JobRequestModel({
    required this.id,
    required this.centerName,
    required this.location,
    required this.postedDate,
    required this.salary,
    required this.position,
    required this.experience,
    this.status = JobRequestStatus.newRequest,
    this.matchScore,
    this.workingHours = '',
    this.description = '',
    this.requirements = const [],
    this.benefits = const [],
    this.logoUrl,
    this.rating = 0,
  });

  final String id;
  final String centerName;
  final String location;
  final String postedDate;
  final String salary;
  final String position;
  final String experience;
  final JobRequestStatus status;

  /// Extra fields only shown in the "deatail of job" bottom sheet.
  final int? matchScore;
  final String workingHours;

  /// The poster's own message, shown above the requirements list.
  final String description;
  final List<String> requirements;
  final List<String> benefits;

  /// Requester's photo and rating, both real columns on `salons` /
  /// `beauty_centers`.
  final String? logoUrl;
  final double rating;

  JobRequestModel copyWith({JobRequestStatus? status}) {
    return JobRequestModel(
      id: id,
      centerName: centerName,
      location: location,
      postedDate: postedDate,
      salary: salary,
      position: position,
      experience: experience,
      status: status ?? this.status,
      matchScore: matchScore,
      workingHours: workingHours,
      description: description,
      requirements: requirements,
      benefits: benefits,
      logoUrl: logoUrl,
      rating: rating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        centerName,
        location,
        postedDate,
        salary,
        position,
        experience,
        status,
        matchScore,
        workingHours,
        description,
        requirements,
        benefits,
        logoUrl,
        rating,
      ];
}
