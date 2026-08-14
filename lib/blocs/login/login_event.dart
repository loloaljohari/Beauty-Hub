import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when the email field changes.
class LoginEmailChanged extends LoginEvent {
  const LoginEmailChanged(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Fired when the password field changes.
class LoginPasswordChanged extends LoginEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object?> get props => [password];
}

/// Toggles the password obscure/visible state.
class LoginPasswordVisibilityToggled extends LoginEvent {
  const LoginPasswordVisibilityToggled();
}

/// Fired when the user taps the "Login" button.
class LoginSubmitted extends LoginEvent {
  const LoginSubmitted();
}

/// Fired when the user taps "Login as guest".
class LoginAsGuestRequested extends LoginEvent {
  const LoginAsGuestRequested();
}

/// Fired when the user taps the Google sign-in button.
class LoginWithGoogleRequested extends LoginEvent {
  const LoginWithGoogleRequested();
}
