import 'package:equatable/equatable.dart';

/// Represents the salon/expert owner profile shown on the Profile
/// screen, post cards, chat list, and reservation cards.
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.name,
    required this.specialty,
    this.avatarUrl,
    this.coursesCount = 0,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.address = '',
    this.bio = '',
  });

  final String id;
  final String name;
  final String specialty;
  final String? avatarUrl;
  final int coursesCount;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final String address;
  final String bio;

  @override
  List<Object?> get props => [
        id,
        name,
        specialty,
        avatarUrl,
        coursesCount,
        postsCount,
        followersCount,
        followingCount,
        address,
        bio,
      ];
}
