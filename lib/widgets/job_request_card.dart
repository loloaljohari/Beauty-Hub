import 'package:flutter/material.dart';
import '../core/localization/l10n/app_localizations.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/job_request_model.dart';

/// Job application card matching the "Job Requests" screen: center
/// name, location, salary, position, experience, and Cancel/Accept
/// actions. Tapping opens the "deatail of job" bottom sheet.
class JobRequestCard extends StatelessWidget {
  const JobRequestCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onCancel,
    required this.onAccept,
  });

  final JobRequestModel job;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.postCardRadius.r(context)),
      child: Container(
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
                CircleAvatar(
                  radius: 22.r(context),
                  backgroundColor: AppColors.avatarPlaceholder,
                  backgroundImage: job.logoUrl==null ?null: NetworkImage(job.logoUrl!),
                ),
                SizedBox(width: AppDimens.spaceSm.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.centerName,
                        style: AppTextStyles.label
                            .copyWith(fontSize: 15.sp(context)),
                      ),
                      Text(
                        '${job.position}  •  ${job.location}',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp(context),
                          color: AppColors.textSecondaryGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  job.salary,
                  style: AppTextStyles.h3.copyWith(
                    fontSize: 15.sp(context),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppDimens.spaceXs.h(context)),
            Text(
              'Experience: ${job.experience}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.sp(context),
                color: AppColors.textSecondaryGrey,
              ),
            ),
            if (job.status == JobRequestStatus.newRequest) ...[
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimens.spaceXs.h(context),
                        ),
                      ),
                      child: Text(context.l10n.cancel),
                    ),
                  ),
                  SizedBox(width: AppDimens.spaceXs.w(context)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(
                          vertical: AppDimens.spaceXs.h(context),
                        ),
                      ),
                      child: Text(context.l10n.accept),
                    ),
                  ),
                ],
              ),
            ] else
              Padding(
                padding: EdgeInsets.only(top: AppDimens.spaceXs.h(context)),
                child: Text(
                  job.status == JobRequestStatus.accepted
                      ? 'Accepted'
                      : 'Rejected',
                  style: TextStyle(
                    fontSize: 12.sp(context),
                    fontWeight: FontWeight.w600,
                    color: job.status == JobRequestStatus.accepted
                        ? AppColors.statusSuccess
                        : AppColors.statusDanger,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
