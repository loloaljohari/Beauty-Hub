import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/job_detail/job_detail_bloc.dart';
import '../../blocs/job_detail/job_detail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';

/// "deatail of job" bottom sheet content - matches Figma's modal
/// frame (height ~390): match score, full requirements, and
/// benefits list. Rendered inside [BottomSheetWrapper] by the
/// caller (see JobRequestsPage._openDetail).
class JobDetailPage extends StatelessWidget {
  const JobDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobDetailBloc, JobDetailState>(
      builder: (context, state) {
        if (state.status != JobDetailStatus.loaded || state.job == null) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final job = state.job!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24.r(context),
                  backgroundColor: AppColors.avatarPlaceholder,
                ),
                SizedBox(width: AppDimens.spaceSm.w(context)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.centerName,
                        style: AppTextStyles.h3
                            .copyWith(fontSize: 17.sp(context)),
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
                if (job.matchScore != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimens.spaceSm.w(context),
                      vertical: AppDimens.spaceXxs.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusSuccess.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${job.matchScore}% Match',
                      style: TextStyle(
                        fontSize: 11.sp(context),
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusSuccess,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            _InfoRow(icon: Icons.attach_money, label: context.l10n.salary, value: job.salary),
            _InfoRow(
              icon: Icons.work_history_outlined,
              label: context.l10n.experience,
              value: job.experience,
            ),
            _InfoRow(
              icon: Icons.schedule_outlined,
              label: context.l10n.workingHours,
              value: job.workingHours,
            ),
            SizedBox(height: AppDimens.spaceMd.h(context)),
            if (job.requirements.isNotEmpty) ...[
              Text(
                context.l10n.requirements,
                style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              for (final req in job.requirements) _BulletItem(text: req),
              SizedBox(height: AppDimens.spaceMd.h(context)),
            ],
            if (job.benefits.isNotEmpty) ...[
              Text(
                context.l10n.benefits,
                style: AppTextStyles.h3.copyWith(fontSize: 15.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              for (final benefit in job.benefits) _BulletItem(text: benefit),
            ],
            SizedBox(height: AppDimens.spaceMd.h(context)),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXxs.h(context)),
      child: Row(
        children: [
          Icon(icon, size: 16.r(context), color: AppColors.textSecondaryGrey),
          SizedBox(width: AppDimens.spaceXs.w(context)),
          Text(
            '$label: ',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              size: 14.r(context), color: AppColors.primary),
          SizedBox(width: AppDimens.spaceXs.w(context)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
            ),
          ),
        ],
      ),
    );
  }
}
