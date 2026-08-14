import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Rounded input field with a leading icon and inline label,
/// matching the Figma "Frame 2 / Frame 11" input style
/// (background #F2F2F7, radius 10, leading icon at 24x24).
class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.label,
    required this.icon,
    this.initialValue,
    this.onChanged,
    this.isPassword = false,
    this.isObscured = true,

    this.onToggleObscure,
    this.keyboardType = TextInputType.text,
    this.errorText, required this.name,
  });

  final String label;
  final IconData icon;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final bool isPassword; final bool name;
  final bool isObscured;
  final VoidCallback? onToggleObscure;
  final TextInputType keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: name?160.w(context): double.infinity,
          height: AppDimens.inputHeight.h(context),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceLg.w(context),
            vertical: AppDimens.spaceSm.h(context),
          ),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 232, 232, 234),
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
                  
                  initialValue: initialValue,
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
