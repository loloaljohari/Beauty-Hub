/// Static spacing, radius, and sizing constants matching the Figma design.
/// These represent the "design" values measured against a 393pt-wide
/// reference frame (iPhone 14/15 width). Use [ResponsiveExtension] from
/// `core/utils/responsive.dart` to scale these for the current device.
class AppDimens {
  AppDimens._();

  /// Reference design width/height the Figma frames were built at.
  static const double designWidth = 393;
  static const double designHeight = 852;

  // Screen padding
  static const double screenPaddingH = 18;
  static const double screenPaddingTop = 42;
  static const double screenPaddingBottom = 42;

  // Container radius
  static const double screenRadius = 30;
  static const double cardRadiusLarge = 32;

  // Spacing
  static const double spaceXxs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 10;
  static const double spaceMd = 14;
  static const double spaceLg = 20;
  static const double spaceXl = 28;
  static const double spaceXxl = 32;

  // Input field
  static const double inputRadius = 10;
  static const double inputHeight = 62;
  static const double inputIconSize = 24;

  // Buttons
  static const double buttonRadius = 20;
  static const double buttonHeight = 56;
  static const double socialButtonRadius = 7;
  static const double socialButtonHeight = 36;

  // OTP box
  static const double otpBoxSize = 63;
  static const double otpRadius = 12;

  // Plan card
  static const double planCardRadius = 24;

  // Basic section
  static const double bottomNavHeight = 93;
  static const double postCardRadius = 14;
  static const double productCardRadius = 12;
  static const double avatarSizeSmall = 49;
  static const double avatarSizeMedium = 53;
  static const double avatarSizeLarge = 95;

  // Menu section
  static const double sideMenuWidth = 280;
  static const double statBadgeRadius = 14;
  static const double bottomSheetRadius = 24;
}
