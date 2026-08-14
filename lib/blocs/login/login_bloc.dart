import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/network/auth_failure.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/auth_repository.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginPasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<LoginSubmitted>(_onSubmitted);
    on<LoginAsGuestRequested>(_onGuestRequested);
    on<LoginWithGoogleRequested>(_onGoogleRequested);
  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(
      state.copyWith(password: event.password, status: LoginStatus.initial),
    );
  }

  void _onPasswordVisibilityToggled(
    LoginPasswordVisibilityToggled event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

 Future<void> _onSubmitted(
  LoginSubmitted event,
  Emitter<LoginState> emit,
) async {
  final emailError = Validators.email(state.email);
  final passwordError = Validators.required(state.password);

  if ( passwordError != null) {
    emit(state.copyWith(
      status: LoginStatus.failure,
      errorMessage: emailError ?? passwordError,
    ));
    return;
  }

  emit(state.copyWith(status: LoginStatus.loading));

  try {
    await const AuthRepository().login(
      email: state.email,
      password: state.password,
    );
    emit(state.copyWith(status: LoginStatus.success));
  } on ApiException catch (e) {
    emit(state.copyWith(
      status: LoginStatus.failure,
      errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
    ));
  } catch (e) {
    emit(state.copyWith(
      status: LoginStatus.failure,
      errorMessage: 'No internet connection',
    ));
  }
}

  Future<void> _onGuestRequested(
    LoginAsGuestRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(status: LoginStatus.success));
  }

  Future<void> _onGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(status: LoginStatus.loading));
    // TODO: Integrate google_sign_in package when ready.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    emit(state.copyWith(status: LoginStatus.success));
  }
}
