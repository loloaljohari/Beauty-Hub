import 'package:flutter/material.dart';

/// Centralized color palette extracted from the Beauty Hub Figma design
/// (Authentication section). Keep all raw color values here so the rest
/// of the app references semantic names instead of hex codes.
class AppColors {
  AppColors._();

  // Brand / Primary
  static const Color primary = Color(0xFF4B1A23); // burgundy
  static const Color primaryDark = Color(0xFF741838);
  static const Color primaryAccent = Color(0xFF8B3344);

  // Text
  static const Color textPrimary = Color(0xFF4B1A23);
  static const Color textBody = Color(0xFF737373);
  static const Color textMuted = Color(0xFF8F7884);
  static const Color textHint = Color(0xFFABABAB);
  static const Color textDark = Color(0xFF231620);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Surfaces / Inputs
  static const Color inputBackground = Color(0xFFF2F2F7);
  static const Color inputBackgroundAlt = Color(0xFFE7E7EE);
  static const Color buttonDisabled = Color(0xFFE7E7EE);
  static const Color buttonDisabledAlt = Color(0xFFE7E7EF);

  // Decorative blur shapes
  static const Color decorativeYellow = Color(0xFFFFEA7C);
  static const Color decorativeRose = Color(0xFFD69A8C);
  static const Color decorativeGold = Color(0xFF8B661D);

  // Social
  static const Color googleBlue = Color(0xFF587DBD);
  static const Color googleRed = Color(0xFFE33629);
  static const Color googleYellow = Color(0xFFF8BD00);
  static const Color googleGreen = Color(0xFF319F43);

  // Misc
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x52FFFFFF);

  // Plan card accents
  static const Color planPillBackground = Color(0xFFF8E9E5);

  // Basic section (Home/Warehouse/Profile/etc.)
  static const Color postCardBackground = Color(0xFFEDEDED);
  static const Color followBackground = Color(0xFFFFEA7C);
  static const Color followText = Color(0xFF4B311A);
  static const Color avatarPlaceholder = Color(0xFF8E8E93);
  static const Color textSecondaryGrey = Color(0xFFAEAEB2);
  static const Color textTertiaryGrey = Color(0xFF676F73);
  static const Color iconActive = Color(0xFF702E3A);
  static const Color imagePlaceholder = Color(0xFFD9D9D9);
  static const Color profileAccent = Color(0xFF591C27);
  static const Color tabInactiveBackground = Color(0xFFE2E2E2);

  // Menu section (Material/Jobs/Salons/Offers/Training/Reviews/Reports/Settings)
  static const Color statusSuccess = Color(0xFF2E7D32);
  static const Color statusWarning = Color(0xFFE08A1E);
  static const Color statusDanger = Color(0xFFD32F2F);
  static const Color chartBarPrimary = Color(0xFF591C27);
  static const Color chartBarSecondary = Color(0xFFE7E7EE);
  static const Color priceOld = Color(0xFFABABAB);
}
