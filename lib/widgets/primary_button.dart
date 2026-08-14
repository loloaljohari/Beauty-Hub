import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Primary call-to-action button matching the Figma "Frame 13/16"
/// pill button style (radius 20, full width, centered label).
///
/// Two visual variants are supported to match the design:
/// - [PrimaryButtonVariant.light]: light grey background
///   (#E7E7EE) with burgundy text - used on Login/Register/Verification.
/// - [PrimaryButtonVariant.filled]: solid burgundy background with
///   white text - used on Check Email / Forgot Password / New Password.
enum PrimaryButtonVariant { light, filled }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PrimaryButtonVariant.light,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final PrimaryButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isFilled = variant == PrimaryButtonVariant.filled;
    final backgroundColor =
        isFilled ? AppColors.primary : Color.fromARGB(255, 231, 231, 231);
    final textColor = isFilled ? AppColors.white : AppColors.textPrimary;

    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonHeight.h(context),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withOpacity(0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22.r(context),
                height: 22.r(context),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: textColor,
                ),
              )
            : Text(
                label,
                style: (isFilled
                        ? AppTextStyles.buttonPrimaryWhite
                        : AppTextStyles.buttonPrimary)
                    .copyWith(fontSize: 18.sp(context)),
              ),
      ),
    );
  }
}
