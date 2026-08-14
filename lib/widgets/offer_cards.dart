import 'package:flutter/material.dart';
import 'state_views.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/offer_models.dart';

/// Service discount card: service name, old/new price, date range,
/// delete action.
class DiscountCard extends StatelessWidget {
  const DiscountCard({super.key, required this.discount, required this.onDelete});

  final DiscountModel discount;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _OfferCardShell(
            packageImage: discount.imageUrl,

      title: discount.serviceName,
      dateRange: '${discount.startDate} - ${discount.endDate}',
      onDelete: onDelete,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            discount.formattedBasicPrice,
            style: TextStyle(
              fontSize: 12.sp(context),
              color: AppColors.priceOld,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            discount.formattedNewPrice,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15.sp(context),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Product offer card: product name, description (e.g. "buy tow and
/// get one free"), date range, delete action.
class OfferCard extends StatelessWidget {
  const OfferCard({super.key, required this.offer, required this.onDelete});

  final OfferModel offer;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _OfferCardShell(   
         packageImage: offer.imageUrl,


      title: offer.productName,
      subtitle: offer.description,
      dateRange: '${offer.startDate} - ${offer.endDate}',
      onDelete: onDelete,
    );
  }
}

/// Bundled package card: name, bio, included items, total/new price,
/// date range, delete action.
class PackageCard extends StatelessWidget {
  const PackageCard({super.key, required this.package, required this.onDelete});

  final PackageModel package;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return _OfferCardShell(
      packageImage: package.imageUrl,

      title: package.name,
      subtitle: package.bio,
      dateRange: '${package.startDate} - ${package.endDate}',
      onDelete: onDelete,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            package.formattedTotalPrice,
            style: TextStyle(
              fontSize: 12.sp(context),
              color: AppColors.priceOld,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          Text(
            package.formattedNewPrice,
            style: AppTextStyles.h3.copyWith(
              fontSize: 15.sp(context),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared visual shell for Discount/Offer/Package cards (same layout
/// pattern across all three Figma tabs).
class _OfferCardShell extends StatelessWidget {
  const _OfferCardShell({
    required this.title,
    required this.dateRange,
    required this.onDelete,
    this.subtitle,
    this.trailing,
    required this.packageImage
  });

  final String title;
  final String? subtitle;
  final String dateRange;
  final VoidCallback onDelete;
  final Widget? trailing;
  final packageImage;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.circular(AppDimens.postCardRadius.r(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CardThumbnail(
            imageUrl: packageImage,
            size: 48.r(context),
            fallbackIcon: Icons.inventory_2_outlined,
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                Text(
                  dateRange,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            trailing!,
            SizedBox(width: AppDimens.spaceXs.w(context)),
          ],
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

/// Single row in the Rewards leaderboard tab: rank, customer name,
/// points.
class RewardCustomerRow extends StatelessWidget {
  const RewardCustomerRow({super.key, required this.rank, required this.name, required this.points});

  final int rank;
  final String name;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceXs.h(context)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.spaceSm.w(context),
        vertical: AppDimens.spaceSm.h(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24.w(context),
            child: Text(
              '#$rank',
              style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
            ),
          ),
          CircleAvatar(
            radius: 16.r(context),
            backgroundColor: AppColors.avatarPlaceholder,
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
            ),
          ),
          Text(
            '$points pts',
            style: AppTextStyles.label.copyWith(
              fontSize: 13.sp(context),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}