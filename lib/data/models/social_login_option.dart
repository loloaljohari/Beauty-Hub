import 'package:equatable/equatable.dart';

/// Represents a third-party authentication provider option
/// (e.g. Google, Apple, Facebook) shown on the Login screen.
class SocialLoginOption extends Equatable {
  const SocialLoginOption({
    required this.id,
    required this.label,
    required this.iconAsset,
  });

  /// Unique provider identifier, e.g. 'google'.
  final String id;

  /// Display label, e.g. 'continue with Google'.
  final String label;

  /// Path to the provider's SVG/PNG icon asset.
  final String iconAsset;

  @override
  List<Object?> get props => [id, label, iconAsset];
}
