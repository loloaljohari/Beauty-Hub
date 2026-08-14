import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/review_model.dart';

/// Customer review card: name, date, star rating, comment,
/// viewed/unviewed indicator, delete action.
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.review, this.onDelete});

  final ReviewModel review;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: review.isViewed ? AppColors.white : AppColors.inputBackground,
        borderRadius:
            BorderRadius.circular(AppDimens.postCardRadius.r(context)),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r(context),
                backgroundColor: AppColors.avatarPlaceholder,
                backgroundImage: review.image==null?null:NetworkImage(review.image),
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 14.sp(context)),
                    ),
                    Text(
                      review.date,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 14.r(context),
                    color: Colors.amber,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 16.r(context)),
                  color: Colors.redAccent,
                ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Text(
            review.comment,
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
          ),
        ],
      ),
    );
  }
}
