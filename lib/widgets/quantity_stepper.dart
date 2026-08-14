import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Reusable "-  N  +" quantity stepper used in the Cart and the
/// Add Service "Minimum number of people" field.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({

    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.spaceXs.r(context),
        vertical: AppDimens.spaceXxs.r(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(icon: Icons.remove, onTap: onDecrement),
          SizedBox(
            width: 35.w(context),
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
            ),
          ),
          _StepButton(icon: Icons.add, onTap: onIncrement),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(AppDimens.spaceXs.r(context)),
        child: Icon(icon, size: 16.r(context), color: AppColors.textPrimary),
      ),
    );
  }
}
