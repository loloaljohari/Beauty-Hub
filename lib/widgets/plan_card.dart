import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/plan_model.dart';

/// Subscription plan card matching the Figma "Subscription plan card"
/// component (radius 24, white translucent background, badge pill,
/// price, description, and CTA button).
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onSelect,
  });

  final PlanModel plan;
  final bool isSelected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimens.spaceLg.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.50),
        borderRadius: BorderRadius.circular(AppDimens.planCardRadius),
        border: isSelected
            ? Border.all(color: AppColors.primaryDark, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.badgeLabel != null) ...[
            _Badge(label: plan.badgeLabel!),
            SizedBox(height: AppDimens.spaceXs.h(context)),
          ],
          Text(
            plan.name,
            style: AppTextStyles.h3.copyWith(fontSize: 19.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXxs.h(context)),
          Text(
            plan.price,
            style: AppTextStyles.planPrice.copyWith(
              fontSize: 30.sp(context),
              color: plan.priceColor,
            ),
          ),
          SizedBox(height: AppDimens.spaceXxs.h(context)),
          Text(
            plan.description,
            style: AppTextStyles.planDescription.copyWith(
              fontSize: 11.sp(context),
            ),
          ),
          SizedBox(height: AppDimens.spaceMd.h(context)),
          _ChooseButton(
            label: plan.ctaLabel,
            isCurrent: plan.isCurrent,
            onTap: onSelect,
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.spaceSm.w(context),
        vertical: 4.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.planPillBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.planBadge.copyWith(fontSize: 10.sp(context)),
      ),
    );
  }
}

class _ChooseButton extends StatelessWidget {
  const _ChooseButton({
    required this.label,
    required this.isCurrent,
    required this.onTap,
  });

  final String label;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isCurrent ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          disabledBackgroundColor: AppColors.primaryDark,
          padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTextStyles.planChoose.copyWith(fontSize: 12.sp(context)),
        ),
      ),
    );
  }
}
