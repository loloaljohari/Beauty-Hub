import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/job_detail/job_detail_bloc.dart';
import '../../blocs/job_detail/job_detail_event.dart';
import '../../blocs/job_requests/job_requests_bloc.dart';
import '../../blocs/job_requests/job_requests_event.dart';
import '../../blocs/job_requests/job_requests_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/bottom_sheet_wrapper.dart';
import '../../widgets/job_request_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stat_badge_row.dart';
import '../job_detail/job_detail_page.dart';

/// Job Requests screen - matches Figma frame "Job Requests" (1067:xxxx).
class JobRequestsPage extends StatelessWidget {
  const JobRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => JobRequestsBloc()..add(const JobRequestsLoaded()),
      child: const _JobRequestsView(),
    );
  }
}

class _JobRequestsView extends StatelessWidget {
  const _JobRequestsView();

  void _openDetail(BuildContext context, String jobId) {
    BottomSheetWrapper.show(
      context,
      BlocProvider(
        create: (_) => JobDetailBloc()..add(JobDetailLoaded(jobId)),
        child: const JobDetailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.jobRequests,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocConsumer<JobRequestsBloc, JobRequestsState>(
        listenWhen: (previous, current) =>
            previous.actionStatus != current.actionStatus,
        listener: (context, state) {
          if (state.actionStatus == JobRequestActionStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          if (state.status == JobRequestsStatus.loading ||
              state.status == JobRequestsStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 140);
          }

          if (state.status == JobRequestsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<JobRequestsBloc>()
                  .add(const JobRequestsLoaded()),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.work_outline,
              title: context.l10n.noJobRequests,
              message:
                  context.l10n.salonInviteHint??
                  'team, their offer will show up here.',
            );
          }

          final bloc = context.read<JobRequestsBloc>();

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async => bloc.add(const JobRequestsLoaded()),
            child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              StatBadgeRow(
                badges: [
                  StatBadge(label: context.l10n.newLabel, value: '${state.newCount}'),
                  StatBadge(
                    label: context.l10n.rejected,
                    value: '${state.rejectedCount}',
                    color: AppColors.statusDanger,
                  ),
                  StatBadge(
                    label: context.l10n.accepted,
                    value: '${state.acceptedCount}',
                    color: AppColors.statusSuccess,
                  ),
                ],
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              for (final job in state.requests)
                JobRequestCard(
                  job: job,
                  onTap: () => _openDetail(context, job.id),
                  onCancel: () =>
                      bloc.add(JobRequestCancelled(job.id)),
                  onAccept: () =>
                      bloc.add(JobRequestAccepted(job.id)),
                ),
            ],
            ),
          );
        },
      ),
    );
  }
}
