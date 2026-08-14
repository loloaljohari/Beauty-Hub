import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// "continue with Google" button matching Figma "Frame 15"
/// (radius 7, white-ish background, Google "G" icon + label).
///
/// The Google "G" logo is drawn with a [CustomPaint] fallback so the
/// widget renders correctly even before the SVG asset is added to
/// `assets/icons/google.svg`. If you add the SVG asset, swap the
/// [_GoogleIcon] for `SvgPicture.asset('assets/icons/google.svg')`.
class SocialLoginButton extends StatelessWidget {
  const SocialLoginButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.socialButtonHeight.h(context),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          side: const BorderSide(color: AppColors.inputBackgroundAlt),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.socialButtonRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 22.r(context),
              height: 22.r(context),
              child:  SvgPicture.asset('assets/icons/google.svg',height: 22,width: 22,),
              
            ),
            SizedBox(width: AppDimens.spaceSm.w(context)),
            Text(
              label,
              style: AppTextStyles.buttonSecondary.copyWith(
                fontSize: 16.sp(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

