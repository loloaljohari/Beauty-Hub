import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/course_model.dart';

/// Row for a single enrolled course on "My Courses":
/// title + provider/year + edit/delete actions.
class CourseListItem extends StatelessWidget {
  const CourseListItem({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
  });

  final CourseModel course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

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
            width: 48.r(context),
            height: 48.r(context),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.school_outlined,
              size: 22.r(context),
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                ),
                Text(
                  '${course.provider} • ${course.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18.r(context)),
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
