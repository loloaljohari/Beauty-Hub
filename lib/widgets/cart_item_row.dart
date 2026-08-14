import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import 'state_views.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/cart_item_model.dart';
import 'quantity_stepper.dart';

/// Single row in the cart: image placeholder + name/salon + price +
/// quantity stepper + subtotal.
class CartItemRow extends StatelessWidget {
  const CartItemRow({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    this.onRemove,
  });

  final CartItemModel item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onRemove;

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
          // The product photo was never loaded here - the row always
          // drew the fallback icon, even when the item had an image.
          CardThumbnail(
            imageUrl: item.product.imageUrl,
            size: 56.r(context),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
                ),
                if (item.product.salonName.isNotEmpty)
                  Text(
                    item.product.salonName,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                SizedBox(height: AppDimens.spaceXxs.h(context)),
                Text(
                  '\$${item.subtotal.toStringAsFixed(0)}',
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15.sp(context),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              QuantityStepper(
                quantity: item.quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
              if (onRemove != null)
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                  ),
                  child: Text(
                    context.l10n.remove,
                    style: TextStyle(fontSize: 11.sp(context)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}