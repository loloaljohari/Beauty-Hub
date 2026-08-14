import 'package:equatable/equatable.dart';

enum ResetPasswordStatus { initial, loading, success, failure }

class ResetPasswordState extends Equatable {
  const ResetPasswordState({
    this.newPassword = '',
    this.confirmPassword = '',
    this.otp = '',
    this.email = '',
    this.isNewObscured = true,
    this.isConfirmObscured = true,
    this.status = ResetPasswordStatus.initial,
    this.errorMessage,
  });

  final String newPassword;
  final String confirmPassword;

  /// Carried over from the "check your email" screen - the backend
  /// verifies it as part of the reset request.
  final String otp;
  final String email;
  final bool isNewObscured;
  final bool isConfirmObscured;
  final ResetPasswordStatus status;
  final String? errorMessage;

  ResetPasswordState copyWith({
    String? newPassword,
    String? confirmPassword,
    String? otp,
    String? email,
    bool? isNewObscured,
    bool? isConfirmObscured,
    ResetPasswordStatus? status,
    String? errorMessage,
  }) {
    return ResetPasswordState(
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      otp: otp ?? this.otp,
      email: email ?? this.email,
      isNewObscured: isNewObscured ?? this.isNewObscured,
      isConfirmObscured: isConfirmObscured ?? this.isConfirmObscured,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        newPassword,
        confirmPassword,
        otp,
        email,
        isNewObscured,
        isConfirmObscured,
        status,
        errorMessage,
      ];
}
