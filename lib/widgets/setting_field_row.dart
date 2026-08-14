import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';

/// A single editable settings row matching the repeated Figma
/// "click to change it" pattern: label + current value + edit icon,
/// opening an inline edit dialog on tap.
class SettingFieldRow extends StatelessWidget {
  const SettingFieldRow({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                  SizedBox(height: 2.h(context)),
                  Text(
                    value.isEmpty ? 'click to change it' : value,
                    style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_outlined, size: 18.r(context), color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

/// Shows a simple text-edit dialog and returns the new value, or
/// null if cancelled. Used by Settings rows to implement the
/// "click to change it" interaction without a dedicated screen per
/// field.
Future<String?> showEditFieldDialog(
  BuildContext context, {
  required String title,
  required String initialValue,
  TextInputType keyboardType = TextInputType.text,
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        keyboardType: keyboardType,
        autofocus: true,
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(controller.text),
          child: Text(context.l10n.save),
        ),
      ],
    ),
  );
}
