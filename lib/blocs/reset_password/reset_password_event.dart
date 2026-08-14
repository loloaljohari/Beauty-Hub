import 'package:equatable/equatable.dart';

abstract class ResetPasswordEvent extends Equatable {
  const ResetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ResetPasswordNewChanged extends ResetPasswordEvent {
  const ResetPasswordNewChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class ResetPasswordConfirmChanged extends ResetPasswordEvent {
  const ResetPasswordConfirmChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class ResetPasswordVisibilityToggled extends ResetPasswordEvent {
  const ResetPasswordVisibilityToggled(this.key);

  /// 'new' or 'confirm'.
  final String key;

  @override
  List<Object?> get props => [key];
}

class ResetPasswordSubmitted extends ResetPasswordEvent {
  const ResetPasswordSubmitted();
}

/// Hands the verified OTP (and the address it belongs to) from the
/// "check your email" screen to the reset form.
class ResetPasswordOtpReceived extends ResetPasswordEvent {
  const ResetPasswordOtpReceived({required this.otp, this.email = ''});

  final String otp;
  final String email;

  @override
  List<Object?> get props => [otp, email];
}
