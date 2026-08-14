import 'package:flutter/material.dart';
import '../core/utils/image_helpers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/material_item_model.dart';
import 'quantity_stepper.dart';

/// Inventory row for a single material item: image placeholder +
/// name + expiry date + quantity stepper + delete action.
class MaterialCard extends StatelessWidget {
  const MaterialCard({
    super.key,
    required this.material,
    required this.onIncrement,
    required this.onDecrement,
    required this.onDelete,
  });

  final MaterialItemModel material;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
      padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppDimens.productCardRadius.r(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52.r(context),
                height: 52.r(context),
                decoration: BoxDecoration(
                  color: AppColors.imagePlaceholder,
                  borderRadius: BorderRadius.circular(10),
                  image: material.imageUrl != null
                      ? DecorationImage(
                          fit: BoxFit.cover,
                          image: remoteImageProvider(material.imageUrl)!,
                        )
                      : null,
                ),
                alignment: Alignment.center,
                child: material.imageUrl != null
                    ? null
                    : Icon(
                        Icons.science_outlined,
                        size: 22.r(context),
                        color: AppColors.textHint,
                      ),
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                    ),
                    SizedBox(height: 2.h(context)),
                    _StatusChip(
                      min: material.min_stock,
                        status: material.status,
                         expiry: material.expiryDate
                         ),
                  ],
                ),
              ),IconButton(
                    onPressed: onDelete,
                    icon: Icon(Icons.delete_outline, size: 22.r(context)),
                    color: Colors.redAccent,
                  ),
             
            ],
          ),
         SizedBox(height: AppDimens.spaceSm.h(context),),
       SizedBox(
            // width: 1.w(context),
            child: Text(
              'the current quantity : ${material.quantity} ',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(fontSize: 12.sp(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.expiry, this.min});

  final MaterialStatus status;
  final String expiry;
  final double? min;
  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      MaterialStatus.normal => ('in Stock', AppColors.statusSuccess),
      MaterialStatus.expiringSoon => ('Expiring soon', AppColors.statusWarning),
      MaterialStatus.outOfStock => ('Out of stock', AppColors.statusDanger),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minimum of Stock :$min',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 11.sp(context),
            color: AppColors.textSecondaryGrey,
          ),
        ),
        SizedBox(width: AppDimens.spaceXs.w(context)),
        Text(
          label,
          style: TextStyle(
              fontSize: 11.sp(context), color: color, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
