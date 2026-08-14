import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/store_metric_model.dart';

/// KPI metric card shown on the "My Store" dashboard
/// (Products / Revenue / Orders).
class StatMetricCard extends StatelessWidget {
  const StatMetricCard({super.key, required this.metric});

  final StoreMetricModel metric;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, size: 22.r(context), color: metric.accentColor),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Text(
            metric.value,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
          Text(
            metric.label,
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
