import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// Generic field change event keyed by field identifier, matching
/// [AuthFieldConfig.key] values (firstName, lastName, phoneNumber,
/// address, email, password, confirmPassword).
class RegisterFieldChanged extends RegisterEvent {
  const RegisterFieldChanged(this.key, this.value);

  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

/// Toggles obscure text for password / confirm password fields.
class RegisterPasswordVisibilityToggled extends RegisterEvent {
  const RegisterPasswordVisibilityToggled(this.key);

  /// 'password' or 'confirmPassword'.
  final String key;

  @override
  List<Object?> get props => [key];
}

/// Fired when the user taps "Register".
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted();
}

class RegisterImagePicked extends RegisterEvent {
  const RegisterImagePicked(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}
