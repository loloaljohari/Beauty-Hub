import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/available_courses/available_courses_bloc.dart';
import '../../blocs/available_courses/available_courses_event.dart';
import '../../blocs/available_courses/available_courses_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/training_cards.dart';

/// "Available Courses" - browse and enroll in courses offered by
/// other salons/centers/academies.
class AvailableCoursesPage extends StatelessWidget {
  const AvailableCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AvailableCoursesBloc()..add(const AvailableCoursesLoaded()),
      child: const _AvailableCoursesView(),
    );
  }
}

class _AvailableCoursesView extends StatelessWidget {
  const _AvailableCoursesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.availableCourses,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<AvailableCoursesBloc, AvailableCoursesState>(
        builder: (context, state) {
          if (state.status != AvailableCoursesStatus.loaded) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              for (final course in state.courses)
                AvailableCourseCard(
                  course: course,
                  isEnrolled: state.enrolledIds.contains(course.id),
                  onEnroll: () => context
                      .read<AvailableCoursesBloc>()
                      .add(CourseEnrollRequested(course.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}
