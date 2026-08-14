import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/reports/reports_bloc.dart';
import '../../blocs/reports/reports_event.dart';
import '../../blocs/reports/reports_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/charts.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/stat_badge_row.dart';
import '../../widgets/state_views.dart';

/// Reports screen - matches Figma frame "Reports" (1138:xxxx):
/// Weekly/Monthly toggle, KPI summary, Booking Report bar chart,
/// Materials Usage donut chart, Revenue Report bar chart.
class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReportsBloc()..add(const ReportsLoaded()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.reports,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state.status == ReportsStatus.loading ||
              state.status == ReportsStatus.initial) {
            return const LoadingState();
          }

          if (state.status == ReportsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  context.read<ReportsBloc>().add(const ReportsLoaded()),
            );
          }

          if (state.summary == null ||
              state.bookingReport == null ||
              state.revenueReport == null) {
            return const LoadingState();
          }

          final bloc = context.read<ReportsBloc>();

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              SegmentedTabBar(
                labels: const ['Weekly', 'Monthly'],
                selectedIndex: state.periodIndex,
                onChanged: (index) =>
                    bloc.add(ReportsPeriodChanged(index)),
              ),
              SizedBox(height: AppDimens.spaceMd.h(context)),
              StatBadgeRow(
                badges: [
                  StatBadge(
                    label: context.l10n.bookings,
                    value: '${state.summary!.totalBookings}',
                  ),
                  StatBadge(
                    label: context.l10n.profit,
                    value: '\$${state.summary!.profit.toStringAsFixed(0)}',
                    color: AppColors.statusSuccess,
                  ),
                  StatBadge(
                    label: context.l10n.materialUsed,
                    value: '${state.summary!.materialsUsed}',
                    color: AppColors.statusWarning,
                  ),
                ],
              ),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              Text(
                context.l10n.bookingReport,
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              SimpleBarChart(points: state.bookingReport!.weeklyPoints),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              Text(
                context.l10n.materialsUsage,
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              MaterialsUsageChart(items: state.materialsUsage),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              Text(
                context.l10n.revenueReport,
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              SimpleBarChart(points: state.revenueReport!.weeklyPoints),
              SizedBox(height: AppDimens.spaceXl.h(context)),
            ],
          );
        },
      ),
    );
  }
}
