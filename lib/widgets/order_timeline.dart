import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/order_model.dart';

/// Vertical status timeline matching the Figma "Order Status" /
/// "Detail of order" screens (Approved → Packed → Shipped →
/// Delivered, each with a date label once completed).
class OrderTimeline extends StatelessWidget {
  const OrderTimeline({super.key, required this.steps});

  final List<OrderTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _TimelineRow(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final OrderTimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step.isCompleted;
    final color = isCompleted ? AppColors.primary : AppColors.textHint;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14.r(context),
                height: 14.r(context),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? color : AppColors.white,
                  border: Border.all(color: color, width: 2),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: isCompleted
                        ? AppColors.primary.withOpacity(0.4)
                        : AppColors.divider,
                  ),
                ),
            ],
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: AppDimens.spaceLg.h(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.status.label,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 14.sp(context),
                      color: isCompleted
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                  if (step.description != null)
                    Text(
                      step.description!,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  Text(
                    step.dateLabel ?? '-',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.sp(context),
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
