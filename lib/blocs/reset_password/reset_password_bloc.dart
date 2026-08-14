import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../core/storage/storage_service.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import 'reset_password_event.dart';
import 'reset_password_state.dart';

class ResetPasswordBloc
    extends Bloc<ResetPasswordEvent, ResetPasswordState> {
  ResetPasswordBloc() : super(const ResetPasswordState()) {
    on<ResetPasswordNewChanged>(_onNewChanged);
    on<ResetPasswordConfirmChanged>(_onConfirmChanged);
    on<ResetPasswordVisibilityToggled>(_onVisibilityToggled);
    on<ResetPasswordSubmitted>(_onSubmitted);
    on<ResetPasswordOtpReceived>(_onOtpReceived);
  }

  /// The OTP is entered on the previous screen ("Check your email");
  /// it has to travel with the reset request because the backend
  /// validates it inside `ResetPasswordRequest`.
  void _onOtpReceived(
    ResetPasswordOtpReceived event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(state.copyWith(otp: event.otp, email: event.email));
  }

  void _onNewChanged(
    ResetPasswordNewChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        newPassword: event.value,
        status: ResetPasswordStatus.initial,
      ),
    );
  }

  void _onConfirmChanged(
    ResetPasswordConfirmChanged event,
    Emitter<ResetPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        confirmPassword: event.value,
        status: ResetPasswordStatus.initial,
      ),
    );
  }

  void _onVisibilityToggled(
    ResetPasswordVisibilityToggled event,
    Emitter<ResetPasswordState> emit,
  ) {
    if (event.key == 'new') {
      emit(state.copyWith(isNewObscured: !state.isNewObscured));
    } else {
      emit(state.copyWith(isConfirmObscured: !state.isConfirmObscured));
    }
  }

  Future<void> _onSubmitted(
    ResetPasswordSubmitted event,
    Emitter<ResetPasswordState> emit,
  ) async {
    final newError = Validators.password(state.newPassword);
    final confirmError = Validators.confirmPassword(
      state.newPassword,
      state.confirmPassword,
    );

    final error = newError ?? confirmError;
    if (error != null) {
      emit(
        state.copyWith(
          status: ResetPasswordStatus.failure,
          errorMessage: error,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ResetPasswordStatus.loading));

    // The address was stored when the OTP was requested, so this still
    // works if the app was restarted between the two screens.
    final email = state.email.isNotEmpty
        ? state.email
        : (await StorageService.getPendingOtpEmail() ?? '');

    if (email.isEmpty || state.otp.isEmpty) {
      emit(state.copyWith(
        status: ResetPasswordStatus.failure,
        errorMessage: 'Your reset code expired. Please request a new one.',
      ));
      return;
    }

    try {
      await const AuthRepository().resetPassword(
        email: email,
        otp: state.otp,
        newPassword: state.newPassword,
        confirmPassword: state.confirmPassword,
      );
      emit(state.copyWith(status: ResetPasswordStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ResetPasswordStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ResetPasswordStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
