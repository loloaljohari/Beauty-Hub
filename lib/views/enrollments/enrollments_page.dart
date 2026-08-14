import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/enrollments/enrollments_bloc.dart';
import '../../blocs/enrollments/enrollments_event.dart';
import '../../blocs/enrollments/enrollments_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/training_cards.dart';

/// "My Enrollments" - In Progress / Completed / Canceled tabs with
/// per-course progress tracking.
class EnrollmentsPage extends StatelessWidget {
  const EnrollmentsPage({super.key, this.courseId});

  /// Scopes the list to one course's trainees. With no id the BLoC
  /// fans out across every course the expert runs, because the backend
  /// only exposes enrollments per course.
  final String? courseId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EnrollmentsBloc()
        ..add(EnrollmentsLoaded(courseId: courseId)),
      child: const _EnrollmentsView(),
    );
  }
}

class _EnrollmentsView extends StatelessWidget {
  const _EnrollmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.myEnrollments,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<EnrollmentsBloc, EnrollmentsState>(
        builder: (context, state) {
          if (state.status != EnrollmentsStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = state.filteredEnrollments;

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                  vertical: AppDimens.spaceSm.h(context),
                ),
                child: SegmentedTabBar(
                  labels: const ['In Progress', 'Completed', 'Canceled'],
                  selectedIndex: state.tabIndex,
                  onChanged: (index) => context
                      .read<EnrollmentsBloc>()
                      .add(EnrollmentsTabChanged(index)),
                ),
              ),
              Expanded(
                child: results.isEmpty
                    ? Center(child: Text(context.l10n.noEnrollments))
                    : ListView(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.screenPaddingH.w(context),
                        ),
                        children: [
                          for (final enrollment in results)
                            EnrollmentCard(enrollment: enrollment),
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
