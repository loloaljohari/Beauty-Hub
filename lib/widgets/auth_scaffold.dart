import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/utils/responsive.dart';

/// Shared scaffold for all authentication screens.
///
/// Wraps [child] in a [SafeArea] + scrollable, horizontally-centered
/// container with rounded corners, matching the Figma "Login" /
/// "Register" / etc. frame (cornerRadius ~30-43, white background).
///
/// Responsive behavior:
/// - On phones, content fills the available width with consistent
///   horizontal padding.
/// - On tablets/large screens, content is centered with a max width
///   so the form doesn't stretch awkwardly edge-to-edge.
/// - The whole body is wrapped in a [SingleChildScrollView] so content
///   never overflows on short screens (e.g. landscape or small phones).
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.child,
    this.showDecorativeShapes = false,
    this.backgroundColor = AppColors.white,
  });

  final Widget child;

  /// Whether to show the decorative blurred yellow/burgundy shapes
  /// from the Login screen background.
  final bool showDecorativeShapes;

  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final maxWidth = ResponsiveUtil.maxContentWidth(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          if (showDecorativeShapes) ..._buildDecorativeShapes(context),
          SafeArea(
            child: SizedBox(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                    vertical: AppDimens.spaceXl.h(context),
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the soft blurred decorative rectangles seen behind the
  /// Login screen's title area.
  List<Widget> _buildDecorativeShapes(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return [
      Positioned(
        top: -size.height * 0.08,
        child:Image.asset(
          'assets/images/back.png',
          fit: BoxFit.cover,
        ),
      )  ];
  }
}
