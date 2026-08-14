import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

/// Generic profile field update keyed by field name (name, phone,
/// email, birthdate, bio, location, instagramHandle, facebookHandle,
/// typeOfWork).
class SettingsFieldChanged extends SettingsEvent {
  const SettingsFieldChanged(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

/// Fired after the user picks a new avatar image via image_picker.
class SettingsAvatarChanged extends SettingsEvent {
  const SettingsAvatarChanged(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class WorkScheduleAdded extends SettingsEvent {
  const WorkScheduleAdded(this.day, this.startTime, this.endTime, this.slot, this.active);

  final String day;
  final String startTime;
  final String endTime;
  final String slot;
  final  active;

  @override
  List<Object?> get props => [day, startTime, endTime];
}

class WorkScheduleRemoved extends SettingsEvent {
  const WorkScheduleRemoved(this.scheduleId);

  final String scheduleId;

  @override
  List<Object?> get props => [scheduleId];
}

class SettingsPasswordChangeSubmitted extends SettingsEvent {
  const SettingsPasswordChangeSubmitted({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

class SettingsLogoutRequested extends SettingsEvent {
  const SettingsLogoutRequested();
}

class SettingsAccountDeletionRequested extends SettingsEvent {
  const SettingsAccountDeletionRequested();
}
