
import 'package:beautyhup/blocs/nav/nav_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/notification/device_token_sync.dart';
import '../../core/network/auth_failure.dart';
import '../../core/utils/validators.dart';
import '../../data/models/settings_models.dart';
import '../../data/repositories/settings_repository.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({SettingsRepository? repository})
      : _repository = repository ?? const SettingsRepository(),
        super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsFieldChanged>(_onFieldChanged);
    on<SettingsAvatarChanged>(_onAvatarChanged);
    on<WorkScheduleAdded>(_onWorkScheduleAdded);
    on<WorkScheduleRemoved>(_onWorkScheduleRemoved);
    on<SettingsPasswordChangeSubmitted>(_onPasswordChangeSubmitted);
    on<SettingsLogoutRequested>(_onLogoutRequested);
    on<SettingsAccountDeletionRequested>(_onAccountDeletionRequested);
  }

  final SettingsRepository _repository;

  Future<void> _onLoaded(
    SettingsLoaded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
      errorMessage: null,
    ));

    try {
      final profile = await _repository.getProfile();
      final schedule = await _repository.getWorkSchedule();

      emit(
        state.copyWith(
          profile: profile,
          workSchedule: schedule,
          weekDays: _repository.getWeekDays(),
          status: SettingsStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SettingsStatus.failure,
        errorMessage: 'Could not load your settings.',
      ));
    }
  }

  Future<void> _onFieldChanged(
    SettingsFieldChanged event,
    Emitter<SettingsState> emit,
  ) async {
    // if (state.profile == null) return;
    emit(state.copyWith(actionStatus: SettingsActionStatus.loading));

    final p = state.profile!;

    try {
      SettingsProfileModel profile;

      switch (event.key) {
        case "name":
          profile = await _repository.updateProfile(
            fullName: event.value,
          );
          break;

        case "phone":
          profile = await _repository.updateProfile(
            phone: event.value,
          );
          break;

        case "email":
          profile = await _repository.updateProfile(
            email: event.value,
          );
          break;

        case "birthdate":
          profile = await _repository.updateProfile(
            birthdate: event.value,
          );
          break;

        case "bio":
          profile = await _repository.updateProfile(
            bio: event.value,
          );
          break;

        case "location":
          profile = await _repository.updateProfile(
            city: event.value,
          );
          break;

        case "specialization":
          profile = await _repository.updateProfile(
            specialization: event.value,
          );
          break;

        default:
          profile = p;
      }

      emit(state.copyWith(
        profile: profile,
        actionStatus: SettingsActionStatus.success,
      ));
    } on ApiException catch (e) {
      // 422s here are real validation errors (duplicate email, bad
      // phone format); showing them is the whole point.
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Could not save your changes.',
      ));
    }
  }

  Future<void> _onAvatarChanged(
    SettingsAvatarChanged event,
    Emitter<SettingsState> emit,
  ) async {
    if (state.profile == null) return;

    emit(state.copyWith(
      actionStatus: SettingsActionStatus.loading,
    ));

    try {
      final profile = await _repository.updateProfile(
        profilePhoto: event.imagePath,
      );

      emit(state.copyWith(
        profile: profile,
        actionStatus: SettingsActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Could not upload your photo.',
      ));
    }
  }

  void _onWorkScheduleAdded(
    WorkScheduleAdded event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(
      status: SettingsStatus.loading,
    ));
    try {
      // addSchedule merges into the existing week and PUTs the whole
      // thing back, because the endpoint replaces the schedule wholesale.
      // It returns the saved week, so no second GET is needed.
      final updated = await _repository.addSchedule(
        event.day,
        event.startTime,
        event.endTime,
        event.slot,
        event.active == true,
      );

      emit(state.copyWith(
        workSchedule: updated,
        status: SettingsStatus.loaded,
        actionStatus: SettingsActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        actionStatus: SettingsActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: SettingsStatus.loaded,
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Could not save this working day.',
      ));
    }
  }

  /// Removing a day used to only drop it from the in-memory list, so
  /// it reappeared on the next load. It now sends the remaining week
  /// to the calendar endpoint.
  Future<void> _onWorkScheduleRemoved(
    WorkScheduleRemoved event,
    Emitter<SettingsState> emit,
  ) async {
    final target = state.workSchedule
        .where((w) => w.id == event.scheduleId)
        .toList();

    if (target.isEmpty) return;

    final previous = state.workSchedule;

    emit(state.copyWith(
      workSchedule: previous.where((w) => w.id != event.scheduleId).toList(),
      actionStatus: SettingsActionStatus.loading,
    ));

    try {
      final updated = await _repository.removeScheduleDay(target.first.day);
      emit(state.copyWith(
        workSchedule: updated,
        actionStatus: SettingsActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        workSchedule: previous,
        actionStatus: SettingsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        workSchedule: previous,
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Could not remove this working day.',
      ));
    }
  }

  Future<void> _onPasswordChangeSubmitted(
    SettingsPasswordChangeSubmitted event,
    Emitter<SettingsState> emit,
  ) async {
    final error = Validators.password(event.newPassword);
    if (error != null) {
      emit(
        state.copyWith(
          actionStatus: SettingsActionStatus.failure,
          errorMessage: error,
        ),
      );
      return;
    }

    emit(state.copyWith(actionStatus: SettingsActionStatus.loading));

    try {
      // POST /expert/auth/change_password. The backend revokes every
      // token on success, so the repository also clears local session
      // state - the screen must route back to login afterwards.
      await _repository.changePassword(
        currentPassword: event.currentPassword,
        newPassword: event.newPassword,
        confirmPassword: event.newPassword,
      );

      emit(state.copyWith(
        actionStatus: SettingsActionStatus.success,
        requiresReLogin: true,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Could not change your password.',
      ));
    }
  }

  Future<void> _onLogoutRequested(
    SettingsLogoutRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: SettingsActionStatus.loading));

    try {
      // Stop pushes reaching this device for an account that just
      // signed out, before the token is thrown away.
      await DeviceTokenSync.stop();

      // The repository clears the token and local user data itself,
      // including when the network call fails.
      await _repository.logout();
      emit(state.copyWith(actionStatus: SettingsActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }

  Future<void> _onAccountDeletionRequested(
    SettingsAccountDeletionRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: SettingsActionStatus.loading));
    try {
      await _repository.deleteAccount();
      emit(state.copyWith(actionStatus: SettingsActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: SettingsActionStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
