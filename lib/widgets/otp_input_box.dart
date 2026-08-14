import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// Single OTP digit box matching Figma "Frame 50-54" (63x63, radius 12,
/// light grey background, centered 24px digit).
class OtpInputBox extends StatelessWidget {
  const OtpInputBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.autofocus = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final size = AppDimens.otpBoxSize.r(context)-10;
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.otpDigit.copyWith(fontSize: 24.sp(context)),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.inputBackground,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.otpRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimens.otpRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}
