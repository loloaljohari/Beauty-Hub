import 'package:equatable/equatable.dart';

/// Status of the login submission.
enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordObscured = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String email;
  final String password;
  final bool isPasswordObscured;
  final LoginStatus status;
  final String? errorMessage;

  /// Whether the form has the minimum data to attempt a submit.
  bool get isFormFilled => email.trim().isNotEmpty && password.isNotEmpty;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordObscured,
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordObscured,
        status,
        errorMessage,
      ];
}
