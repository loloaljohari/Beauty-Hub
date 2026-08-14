import 'package:beautyhup/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

/// A single working day entry shown in Settings → "Time of Work",
/// and created/edited via the "add time to work" bottom sheet.
class WorkScheduleModel extends Equatable {
  const WorkScheduleModel({
    required this.id,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.slotDuration,
  });

  final String id;
  final String day;
  final String startTime;
  final String endTime;
  final bool isActive;
  final String slotDuration;

  String get formattedRange => '$startTime - $endTime';

  @override
  List<Object?> get props => [id, day, startTime, endTime];
}

/// Full editable profile/settings data, expanding on the simpler
/// [UserModel] used elsewhere in the app.
class SettingsProfileModel extends Equatable {
  const SettingsProfileModel({
    required this.name,
    required this.phone,
    required this.email,
    required this.birthdate,
    required this.bio,
    required this.location,
    required this.instagramHandle,
    required this.facebookHandle,
    required this.typeOfWork,
    required this.experienceYears,
    required this.followingCount,
    required this.avatarUrl,
    required this.followersCount,
  });

  final String name;
  final String phone;
  final String email;
  final String birthdate;
  final String bio;
  final String location;
  final String instagramHandle;
  final String facebookHandle;
  final String typeOfWork;
  final int experienceYears;
  final String? avatarUrl;
  final int followingCount; 
  final int followersCount ; // Placeholder value, replace with actual data if available

  SettingsProfileModel copyWith({
    String? name,
    String? phone,
    String? email,
    String? birthdate,
    String? bio,
    String? location,
    String? instagramHandle,
    String? facebookHandle,
    String? typeOfWork,
    int? experienceYears,
    String? avatarUrl,
    int? followingCount,
    int? followersCount,
  }) {
    return SettingsProfileModel(
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,    
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      facebookHandle: facebookHandle ?? this.facebookHandle,
      typeOfWork: typeOfWork ?? this.typeOfWork,
      experienceYears: experienceYears ?? this.experienceYears,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [
        name,
        phone,
        email,
        birthdate,
        bio,
        location,
        instagramHandle,
        facebookHandle,
        typeOfWork,
        experienceYears,
        avatarUrl,
        followingCount,
        followersCount,
      ];

 

  UserModel toUserModel() {
    return UserModel(
      id: '', // You can set the ID if available
      name: name,
      avatarUrl: avatarUrl,
      bio: bio,
      specialty: typeOfWork,
      address: location,
    );
  }
}
