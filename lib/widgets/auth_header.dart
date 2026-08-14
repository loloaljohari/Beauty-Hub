import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Shared header used by Verification, Check Email, Forgot Password,
/// and New Password screens: a back button, title, and optional
/// subtitle/description text.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.showBackButton = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
     
        Text(
          title,
          style: AppTextStyles.h2.copyWith(fontSize: 24.sp(context)),
        ),
        if (subtitle != null) ...[
          SizedBox(height: AppDimens.spaceSm.h(context)),
          Text(
            subtitle!,
            style: AppTextStyles.bodyMediumBold.copyWith(
              fontSize: 16.sp(context),
              color: AppColors.textBody,
            ),
          ),
        ],
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(27),
      child: Container(
        width: 54.r(context),
        height: 54.r(context),
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.inputBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: AppColors.textPrimary,
          size: 22.r(context),
        ),
      ),
    );
  }
}
