import 'package:flutter/material.dart';
import '../constants/app_dimens.dart';

/// Responsive scaling helpers.
///
/// The Figma design was built on a 393x852 reference frame (iPhone 14/15).
/// These extensions scale dimensions, fonts, and paddings proportionally
/// to the current device's screen size so the UI fits phones of any
/// width/height while preserving the design's proportions.
///
/// Usage:
/// ```dart
/// Container(
///   width: 314.w(context),
///   height: 62.h(context),
///   padding: EdgeInsets.symmetric(horizontal: 18.w(context)),
/// )
/// Text('Login', style: AppTextStyles.h1.copyWith(fontSize: 32.sp(context)))
/// ```
extension ResponsiveExtension on num {
  /// Scales a horizontal dimension relative to the design width (393).
  double w(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / AppDimens.designWidth;
    return this * scale;
  }

  /// Scales a vertical dimension relative to the design height (852).
  double h(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final scale = screenHeight / AppDimens.designHeight;
    return this * scale;
  }

  /// Scales a font size using the smaller of width/height scale factors,
  /// clamped to avoid text becoming too small or too large on extreme
  /// aspect ratios (tablets, foldables, small phones).
  double sp(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final widthScale = size.width / AppDimens.designWidth;
    final heightScale = size.height / AppDimens.designHeight;
    final scale = widthScale < heightScale ? widthScale : heightScale;
    final clamped = scale.clamp(0.8, 1.3);
    return this * clamped;
  }

  /// Generic scale factor based on width - useful for radii/icon sizes
  /// where slight stretching on tablets is undesirable.
  double r(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = screenWidth / AppDimens.designWidth;
    final clamped = scale.clamp(0.85, 1.25);
    return this * clamped;
  }
}

/// Convenience helpers for common responsive breakpoints / checks.
class ResponsiveUtil {
  ResponsiveUtil._();

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600;

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;

  /// Returns a max-width constraint for content on large screens
  /// (tablets / web / desktop) so auth forms don't stretch edge to edge.
  static double maxContentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 600) return 480;
    return width;
  }
}
