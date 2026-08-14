import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/utils/image_helpers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/product_model.dart';

/// Product grid card used on Warehouse and My Store screens:
/// image placeholder + name + (salon name or stock badge) + price +
/// heart/cart action icons.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.onCartTap,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showManagementBadge = false,
  });

  final ProductModel product;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onCartTap;
  final VoidCallback? onTap;

  /// Only supplied for the expert's OWN products, where the card gains
  /// an edit/delete menu instead of the buy action.
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  /// When true (My Store grid), shows a stock status badge instead
  /// of favorite/cart actions.
  final bool showManagementBadge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: const Color.fromARGB(78, 0, 0, 0), blurRadius: 4, offset: Offset(0, 2))
          ],
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppDimens.productCardRadius.r(context)),
          border: Border.all(color: AppColors.divider),

        ),
        child: Column(
          children: [
            SizedBox(
              height: 200, 
               width: 170, 
              child: Stack(
                fit: StackFit.expand,
                children: [
                  
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                          AppDimens.productCardRadius.r(context)),
                      topRight: Radius.circular(
                          AppDimens.productCardRadius.r(context)),
                    ),
                    // Was `Image.asset(product.imageUrl!)`: it force-
                    // unwrapped a nullable field (crash when a product
                    // has no image) AND loaded a server path as a local
                    // asset, which can never resolve.
                    child: _productImage(product.imageUrl),
                  ),
                  // 2. التدرج الأبيض (Gradient) في الأسفل
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80, // يحدد مدى ارتفاع التدرج الأبيض فوق الصورة
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white
                                .withOpacity(0.0), // يبدأ شفافاً من الأعلى
                            Colors.white, // ينتهي بلون أبيض نقي في الأسفل
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppDimens.spaceXs.h(context)),
                  Text(
                    product.name,
                    style: AppTextStyles.label.copyWith(
                        fontSize: 10.sp(context), fontWeight: FontWeight.bold),
                  ),
                  if (product.salonName.isNotEmpty)
                    Text(
                      product.salonName,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  SizedBox(height: AppDimens.spaceXxs.h(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product.formattedPrice,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 15.sp(context),
                          color: AppColors.primary,
                        ),
                      ),
                      if (showManagementBadge)
                        // The expert's own product: stock at a glance,
                        // plus edit/delete when the caller supplies them.
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StockBadge(status: product.stockStatus),
                            if (onEdit != null || onDelete != null)
                              SizedBox(
                                width: 28.r(context),
                                child: PopupMenuButton<String>(
                                  padding: EdgeInsets.zero,
                                  iconSize: 18.r(context),
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: AppColors.textPrimary,
                                  ),
                                  onSelected: (value) {
                                    if (value == 'edit') onEdit?.call();
                                    if (value == 'delete') onDelete?.call();
                                  },
                                  itemBuilder: (_) => [
                                    if (onEdit != null)
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text(context.l10n.edit),
                                      ),
                                    if (onDelete != null)
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text(context.l10n.delete),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            // GestureDetector(
                            //   onTap: onFavoriteTap,
                            //   child: Icon(
                            //     product.isFavorite
                            //         ? Icons.favorite
                            //         : Icons.favorite_border,
                            //     size: 18.r(context),
                            //     color: product.isFavorite
                            //         ? AppColors.profileAccent
                            //         : AppColors.textPrimary,
                            //   ),
                            // ),

                            SizedBox(width: AppDimens.spaceXs.w(context)),
                            GestureDetector(
                              onTap: onCartTap,
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 24.r(context),
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.status});

  final StockStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      StockStatus.inStock => ('In stock', Colors.green),
      StockStatus.lowStock => ('Low stock', Colors.orange),
      StockStatus.outOfStock => ('Out of stock', Colors.redAccent),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.spaceXs.w(context),
        vertical: 2.h(context),
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp(context),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Product artwork, or the shared placeholder when there is none.
///
/// Products come from the API with a relative storage path, so the URL
/// is resolved the same way as everywhere else in the app.
Widget _productImage(String? path) {
  final url = remoteImageUrl(path);

  if (url == null) {
    return Container(
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.avatarPlaceholder,
      ),
    );
  }

  return Image.network(
    url,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      color: AppColors.imagePlaceholder,
      alignment: Alignment.center,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.avatarPlaceholder,
      ),
    ),
  );
}
