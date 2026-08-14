import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/utils/responsive.dart';

/// Horizontal step progress indicator for the multi-step
/// "Add service" wizard (4 segments, current/completed highlighted).
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          Expanded(
            child: Container(
              height: 6.h(context),
              decoration: BoxDecoration(
                color: i <= currentStep
                    ? AppColors.primary
                    : AppColors.tabInactiveBackground,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (i != totalSteps - 1) SizedBox(width: AppDimens.spaceXs.w(context)),
        ],
      ],
    );
  }
}
