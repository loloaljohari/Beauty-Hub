import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/utils/responsive.dart';

/// Shared rounded-top bottom sheet shell used for "deatail of job"
/// and "add time to work". Closes via swipe-down or tapping outside,
/// matching standard [showModalBottomSheet] behavior.
class BottomSheetWrapper extends StatelessWidget {
  const BottomSheetWrapper({super.key, required this.child, this.maxHeightFactor = 0.85});

  final Widget child;
  final double maxHeightFactor;

  /// Convenience launcher.
  static Future<T?> show<T>(BuildContext context, Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BottomSheetWrapper(child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimens.bottomSheetRadius.r(context)),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Container(
                width: 44.w(context),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.screenPaddingH.w(context),
                    vertical: AppDimens.spaceSm.h(context),
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
