import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Reusable pill-shaped two-option tab switcher matching the Figma
/// top-tab pattern used on Warehouse/My Store, Reservations
/// (Booking/Products), and My Cart & Orders (my cart/my orders).
class SegmentedTabBar extends StatelessWidget {
  const SegmentedTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r(context)),
      decoration: BoxDecoration(
        color: AppColors.tabInactiveBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    vertical: AppDimens.spaceXs.h(context),
                  ),
                  decoration: BoxDecoration(
                    color:
                        i == selectedIndex ? AppColors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: i == selectedIndex
                        ? [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 13.sp(context),
                      color: i == selectedIndex
                          ? AppColors.textPrimary
                          : AppColors.textSecondaryGrey,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
