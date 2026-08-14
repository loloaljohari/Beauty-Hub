import 'package:equatable/equatable.dart';

enum SalonType { salon, center }

/// A single employee shown on the salon detail "Info" tab.
class EmployeeModel extends Equatable {
  const EmployeeModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.image
  });

  final String id;
  final String name;
  final String specialty;
  final image;

  @override
  List<Object?> get props => [id, name, specialty,image];
}

/// A salon or beauty center listing, browsable from "Salons &
/// Centers" and shown in full on "detail of salon".
class SalonModel extends Equatable {
  const SalonModel({
    required this.id,
    required this.name,
    required this.type,
    required this.city,
    this.subtitle = '',
    this.rating = 0,
    this.reviewsCount = 0,
    this.description = '',
    this.phoneNumbers = const [],
    this.socialMediaHandles = const [],
    this.address = '',
    this.services = const [],
    this.employees = const [],
    this.isFollowing = false,
    this.imageUrl,
    this.coverUrl,
  });

  final String id;
  final String name;
  final SalonType type;
  final String city;
  final String subtitle;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> phoneNumbers;
  final List<String> socialMediaHandles;
  final String address;
  final List<String> services;
  final List<EmployeeModel> employees;
  final bool isFollowing;

  /// Profile and cover photos, already absolute.
  final String? imageUrl;
  final String? coverUrl;

  SalonModel copyWith({
    bool? isFollowing,
    List<String>? services,
    List<EmployeeModel>? employees,
  }) {
    return SalonModel(
      id: id,
      name: name,
      type: type,
      city: city,
      subtitle: subtitle,
      rating: rating,
      reviewsCount: reviewsCount,
      description: description,
      phoneNumbers: phoneNumbers,
      socialMediaHandles: socialMediaHandles,
      address: address,
      services: services ?? this.services,
      employees: employees ?? this.employees,
      isFollowing: isFollowing ?? this.isFollowing,
      imageUrl: imageUrl,
      coverUrl: coverUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        city,
        subtitle,
        rating,
        reviewsCount,
        description,
        phoneNumbers,
        socialMediaHandles,
        address,
        services,
        employees,
        isFollowing,
        imageUrl,
        coverUrl,
      ];
}
