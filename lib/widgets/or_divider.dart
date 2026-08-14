import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// "── or ──" divider used between the Login button and the
/// social login options.
class OrDivider extends StatelessWidget {
  const OrDivider({super.key, this.label = 'or'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.spaceSm.w(context)),
          child: Text(
            label,
            style: AppTextStyles.link.copyWith(
              fontSize: 16.sp(context),
              fontWeight: FontWeight.w400,
              color: AppColors.black.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.divider, thickness: 1),
        ),
      ],
    );
  }
}
