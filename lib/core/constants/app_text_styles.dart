import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text styles matching the Figma typography
/// (SF Pro Display, SF Pro Text, Benne for the logo).
///
/// NOTE: All sizes here are "design size" (as exported from Figma at a
/// 393-logical-pixel-wide reference frame). They are passed through
/// [AppDimens.fontSize] at usage time (via [BuildContext] extensions)
/// for responsive scaling - see core/utils/responsive.dart.
class AppTextStyles {
  AppTextStyles._();

  static const String fontFamilyDisplay = 'SFProDisplay';
  static const String fontFamilyText = 'SFProText';
  static const String fontFamilyLogo = 'Benne';

  // Logo
  static const TextStyle logo = TextStyle(
    fontFamily: fontFamilyLogo,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 19,
    fontWeight: FontWeight.w700,
    color: AppColors.profileAccent,
  );

  // Welcome / subtitle text
  static const TextStyle welcome = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // Body
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
  );

  static const TextStyle bodyMediumBold = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textBody,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  // Labels (input field labels)
  static const TextStyle label = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // Links / actions
  static const TextStyle link = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const TextStyle linkUnderline = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
    decoration: TextDecoration.underline,
  );

  // Buttons
  static const TextStyle buttonPrimary = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonPrimaryWhite = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle buttonSecondary = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // OTP digit
  static const TextStyle otpDigit = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  // Timer / order text
  static const TextStyle timerText = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.black,
  );

  static const TextStyle orderAction = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textHint,
  );

  // Plan screen
  static const TextStyle planTitle = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  static const TextStyle planPrice = TextStyle(
    fontFamily: fontFamilyDisplay,
    fontSize: 30,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle planDescription = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
  );

  static const TextStyle planBadge = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryDark,
  );

  static const TextStyle planChoose = TextStyle(
    fontFamily: fontFamilyText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );
}
