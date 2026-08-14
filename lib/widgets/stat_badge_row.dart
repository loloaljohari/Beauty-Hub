import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// A single labeled count badge (e.g. "24 Items", "5 New").
class StatBadge extends Equatable {
  const StatBadge({
    required this.label,
    required this.value,
    this.color = AppColors.primary,
  });

  final String label;
  final String value;
  final Color color;

  @override
  List<Object?> get props => [label, value, color];
}

/// Shared row of stat badges matching the repeated Figma pattern
/// used on Material Inventory (Items/Expiring/Out of stock), Job
/// Requests (New/Rejected/Accepted), and Reviews
/// (Average rating/Total reviews).
class StatBadgeRow extends StatelessWidget {
  const StatBadgeRow({super.key, required this.badges});

  final List<StatBadge> badges;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < badges.length; i++) ...[
          Expanded(child: _StatBadgeTile(badge: badges[i])),
          if (i != badges.length - 1)
            SizedBox(width: AppDimens.spaceXs.w(context)),
        ],
      ],
    );
  }
}

class _StatBadgeTile extends StatelessWidget {
  const _StatBadgeTile({required this.badge});

  final StatBadge badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.spaceSm.w(context),
        vertical: AppDimens.spaceSm.h(context),
      ),
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppDimens.statBadgeRadius.r(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            badge.value,
            style: AppTextStyles.h3.copyWith(
              fontSize: 18.sp(context),
              color: badge.color,
            ),
          ),
          Text(
            badge.label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
        ],
      ),
    );
  }
}
