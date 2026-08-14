import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Describes a single text input field used across the auth forms
/// (Login, Register, Forgot Password, New Password).
///
/// Using a model lets each screen render its form fields by mapping
/// over a static list, avoiding duplicated widget code.
class AuthFieldConfig extends Equatable {
  const AuthFieldConfig({
    required this.key,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
  });

  /// Unique key identifying this field (used by the BLoC to map
  /// field changes to state, e.g. 'email', 'password', 'firstName').
  final String key;

  /// Floating / inline label shown inside the field.
  final String label;

  /// Leading icon for the field.
  final IconData icon;

  /// Whether this field should obscure text and show a visibility toggle.
  final bool isPassword;

  /// Keyboard type to use for this field.
  final TextInputType keyboardType;

  @override
  List<Object?> get props => [key, label, icon, isPassword, keyboardType];
}
