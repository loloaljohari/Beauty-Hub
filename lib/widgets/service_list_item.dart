import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/service_model.dart';

/// Editable row for a single service on the Profile "Services" tab:
/// image placeholder + name + description + price/duration +
/// edit/delete actions.
class ServiceListItem extends StatelessWidget {
  const ServiceListItem({
    super.key,
    required this.service,
    this.onEdit,
    this.onDelete,
    this.onManageMaterials,
  });

  final ServiceModel service;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// Opens the materials this service consumes per session. Optional so
  /// existing usages of this widget keep working unchanged.
  final VoidCallback? onManageMaterials;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.productCardRadius.r(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 56.r(context),
            height: 56.r(context),
            decoration: BoxDecoration(
              color: AppColors.imagePlaceholder,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.spa_outlined,
              size: 24.r(context),
              color: AppColors.textHint,
            ),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
                ),
                Text(
                  service.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
                Text(
                  '${service.formattedPrice}  •  ${service.formattedDuration}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (onManageMaterials != null)
            IconButton(
              onPressed: onManageMaterials,
              icon: Icon(Icons.science_outlined, size: 18.r(context)),
              color: AppColors.textPrimary,
              tooltip: 'Materials',
            ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18.r(context)),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline, size: 18.r(context)),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
