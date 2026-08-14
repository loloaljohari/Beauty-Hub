import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Rounded input field with a leading icon and inline label,
/// matching the Figma "Frame 2 / Frame 11" input style
/// (background #F2F2F7, radius 10, leading icon at 24x24).
class FeildSer extends StatelessWidget {
  const FeildSer({
    super.key,
    required this.label,
    required this.icon,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.isPassword = false,
    this.isObscured = true,
    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.errorText,
    this.textController
  });

  final String label;
  final IconData icon;

  /// Optional external controller. When provided, [initialValue] is
  /// ignored (the controller owns the text); pass this when the
  /// parent needs to programmatically read/clear the field (e.g.
  /// "Add an instruction" inputs in the Add Service wizard).
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool isPassword;
  final bool isObscured;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? errorText;
   final String? textController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg.w(context),
            vertical: AppDimens.spaceSm.h(context),
          ),
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(AppDimens.inputRadius),
            border: errorText != null
                ? Border.all(color: Colors.redAccent, width: 1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppDimens.inputIconSize.r(context),
                color: AppColors.textPrimary.withOpacity(0.83),
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  initialValue: controller == null ? initialValue : null,
                  onChanged: onChanged,
                  obscureText: isPassword && isObscured,
                  keyboardType: keyboardType,
                  style: AppTextStyles.label.copyWith(
                    fontWeight: FontWeight.w400,
                    fontSize: 14.sp(context),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintText: label,
                    hintStyle: AppTextStyles.label.copyWith(
                      fontSize: 14.sp(context),
                      color: AppColors.textPrimary.withOpacity(0.83),
                    ),
                  ),
                ),
              ),
              if (isPassword)
                GestureDetector(
                  onTap: onToggleObscure,
                  child: Icon(
                    isObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: AppDimens.inputIconSize.r(context),
                    color: AppColors.textPrimary.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: AppDimens.spaceXxs.h(context)),
          Padding(
            padding: EdgeInsets.only(left: AppDimens.spaceXs.w(context)),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 12.sp(context),
                fontFamily: AppTextStyles.fontFamilyText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
