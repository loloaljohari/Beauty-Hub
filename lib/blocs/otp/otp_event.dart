import 'package:equatable/equatable.dart';

abstract class OtpEvent extends Equatable {
  const OtpEvent();

  @override
  List<Object?> get props => [];
}

/// Fired whenever a single OTP digit input changes.
class OtpDigitChanged extends OtpEvent {
  const OtpDigitChanged(this.index, this.value);

  final int index;
  final String value;

  @override
  List<Object?> get props => [index, value];
}

/// Internal tick event used by the resend countdown timer.
class OtpCountdownTicked extends OtpEvent {
  const OtpCountdownTicked(this.remainingSeconds);

  final int remainingSeconds;

  @override
  List<Object?> get props => [remainingSeconds];
}

/// Fired when the user taps "Order" to resend the code.
///
/// [email] is optional: screens that know the address pass it, the
/// rest fall back to the pending address kept in local storage.
class OtpResendRequested extends OtpEvent {
  const OtpResendRequested({this.email});

  final String? email;

  @override
  List<Object?> get props => [email];
}

/// Fired when the user taps "Continue".
class OtpSubmitted extends OtpEvent {
  final String email;
  const OtpSubmitted({required this.email});
}

/// Starts the countdown timer (called once when the screen loads).
class OtpCountdownStarted extends OtpEvent {
  const OtpCountdownStarted();
}
