import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import 'state_views.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/training_models.dart';

/// Card for a course the expert teaches, on "My Courses" (under
/// Training & Courses).
class ManagedCourseCard extends StatelessWidget {
  const ManagedCourseCard({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
    this.onViewStudents,
  });

  final ManagedCourseModel course;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onViewStudents;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CardThumbnail(
                imageUrl: course.imageUrl,
                size: 56.r(context),
                fallbackIcon: Icons.school_outlined,
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 15.sp(context)),
                    ),
                    Text(
                      'Published: ${course.publishedDate}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                course.formattedPrice,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 15.sp(context),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Row(
            children: [
              Icon(Icons.people_outline,
                  size: 14.r(context), color: AppColors.textSecondaryGrey),
              SizedBox(width: 4.w(context)),
              Text(
                '${course.studentsCount} students',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp(context)),
              ),
              SizedBox(width: AppDimens.spaceSm.w(context)),
              Icon(Icons.menu_book_outlined,
                  size: 14.r(context), color: AppColors.textSecondaryGrey),
              SizedBox(width: 4.w(context)),
              Text(
                '${course.lessonsCount} lessons',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp(context)),
              ),
            ],
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewStudents,
                  child: Text(context.l10n.students),
                ),
              ),
              SizedBox(width: AppDimens.spaceXs.w(context)),
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
        ],
      ),
    );
  }
}

/// Card for a course offered by another provider, on "Available
/// Courses".
class AvailableCourseCard extends StatelessWidget {
  const AvailableCourseCard({
    super.key,
    required this.course,
    required this.isEnrolled,
    required this.onEnroll,
  });

  final AvailableCourseModel course;
  final bool isEnrolled;
  final VoidCallback onEnroll;

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
            imageUrl: course.imageUrl,
            size: 56.r(context),
            fallbackIcon: Icons.school_outlined,
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.title,
                  style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                ),
                Text(
                  course.providerName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
                Text(
                  'Starts: ${course.startDate}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                course.formattedPrice,
                style: AppTextStyles.h3.copyWith(
                  fontSize: 14.sp(context),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              ElevatedButton(
                onPressed: isEnrolled ? null : onEnroll,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimens.spaceSm.w(context),
                  ),
                ),
                child: Text(isEnrolled ? 'Enrolled' : 'Enroll now'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card for an enrolled course, on "My Enrollments", with a progress
/// bar.
class EnrollmentCard extends StatelessWidget {
  const EnrollmentCard({super.key, required this.enrollment, this.onContinue});

  final EnrollmentModel enrollment;
  final VoidCallback? onContinue;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            enrollment.title,
            style: AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
          ),
          Text(
            enrollment.providerName,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: enrollment.progressPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.tabInactiveBackground,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: AppDimens.spaceXxs.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${enrollment.completedLessons}/${enrollment.totalLessons} lessons',
                style: AppTextStyles.bodySmall.copyWith(fontSize: 11.sp(context)),
              ),
              Text(
                '${enrollment.progressPercent}%',
                style: AppTextStyles.label.copyWith(
                  fontSize: 12.sp(context),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (enrollment.status == EnrollmentStatus.inProgress) ...[
            SizedBox(height: AppDimens.spaceXs.h(context)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: Text(context.l10n.continueLearning),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Card for a completion certificate, on "My Certificates".
class CertificateCard extends StatelessWidget {
  const CertificateCard({
    super.key,
    required this.certificate,
    this.onDownload,
    this.onDelete,
  });

  final CertificateModel certificate;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

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
          Container(
            width: 48.r(context),
            height: 48.r(context),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.workspace_premium_outlined,
                size: 22.r(context), color: AppColors.primary),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                ),
                Text(
                  '${certificate.providerName} • ${certificate.year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDownload,
            icon: Icon(Icons.download_outlined, size: 18.r(context)),
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