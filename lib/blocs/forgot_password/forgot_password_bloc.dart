import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';

class ForgotPasswordBloc
    extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  ForgotPasswordBloc() : super(const ForgotPasswordState()) {
    on<ForgotPasswordEmailChanged>(_onEmailChanged);
    on<ForgotPasswordSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    ForgotPasswordEmailChanged event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(
      state.copyWith(
        email: event.email,
        status: ForgotPasswordStatus.initial,
      ),
    );
  }

  Future<void> _onSubmitted(
    ForgotPasswordSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    final emailError = Validators.email(state.email);
    if (emailError != null) {
      emit(
        state.copyWith(
          status: ForgotPasswordStatus.failure,
          errorMessage: emailError,
        ),
      );
      return;
    }

    emit(state.copyWith(status: ForgotPasswordStatus.loading));

    // POST /expert/auth/forget_password - the backend mails a 6-digit
    // OTP and stores it on the expert row. The address is persisted by
    // the repository so the reset screen can send it back later.
    try {
      await const AuthRepository().forgetPassword(email: state.email.trim());
      emit(state.copyWith(status: ForgotPasswordStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ForgotPasswordStatus.failure,
        errorMessage: 'Something went wrong. Please try again.',
      ));
    }
  }
}
