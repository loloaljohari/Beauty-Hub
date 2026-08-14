import 'package:equatable/equatable.dart';
import '../../data/models/settings_models.dart';

enum SettingsStatus { initial, loading, loaded, failure }
enum SettingsActionStatus { idle, loading, success, failure }

class SettingsState extends Equatable {
  const SettingsState({
    this.profile,
    this.workSchedule = const [],
    this.weekDays = const [],
    this.status = SettingsStatus.initial,
    this.actionStatus = SettingsActionStatus.idle,
    this.errorMessage,
    this.requiresReLogin = false,
  });

  final SettingsProfileModel? profile;
  final List<WorkScheduleModel> workSchedule;
  final List<String> weekDays;
  final SettingsStatus status;

  /// Tracks async actions like password change / logout / delete,
  /// separate from the initial page-load [status].
  final SettingsActionStatus actionStatus;
  final String? errorMessage;

  /// Set after a successful password change: the backend revokes every
  /// token, so the screen has to send the user back to login.
  final bool requiresReLogin;

  SettingsState copyWith({
    SettingsProfileModel? profile,
    List<WorkScheduleModel>? workSchedule,
    List<String>? weekDays,
    SettingsStatus? status,
    SettingsActionStatus? actionStatus,
    String? errorMessage,
    bool? requiresReLogin,
  }) {
    return SettingsState(
      profile: profile ?? this.profile,
      workSchedule: workSchedule ?? this.workSchedule,
      weekDays: weekDays ?? this.weekDays,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
      requiresReLogin: requiresReLogin ?? this.requiresReLogin,
    );
  }

  @override
  List<Object?> get props => [
        profile,
        workSchedule,
        weekDays,
        status,
        actionStatus,
        errorMessage,
        requiresReLogin,
      ];
}
