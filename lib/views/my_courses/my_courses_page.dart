import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/routes/route_names.dart';
import '../../widgets/state_views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/my_courses/my_courses_bloc.dart';
import '../../blocs/my_courses/my_courses_event.dart';
import '../../blocs/my_courses/my_courses_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/course_list_item.dart';

/// My Courses screen - matches Figma frame "My courses" (948:2978).
class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MyCoursesBloc()..add(const MyCoursesLoaded()),
      child: const _MyCoursesView(),
    );
  }
}

class _MyCoursesView extends StatelessWidget {
  const _MyCoursesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.myCourses,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          // Unique tag: FABs default to a shared Hero tag, which
          // throws when two screens with one are on screen together.
          heroTag: 'my_courses_fab',
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final saved =
                await Navigator.of(context).pushNamed(RouteNames.addCourse);

            if (saved == true && context.mounted) {
              context.read<MyCoursesBloc>().add(const MyCoursesLoaded());
            }
          },
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
      body: BlocBuilder<MyCoursesBloc, MyCoursesState>(
        builder: (context, state) {
          if (state.status == MyCoursesStatus.loading ||
              state.status == MyCoursesStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 92);
          }

          if (state.status == MyCoursesStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<MyCoursesBloc>()
                  .add(const MyCoursesLoaded()),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.school_outlined,
              title: context.l10n.noCoursesYet,
              message:
                  context.l10n.publishCourseHint??
                  'in it.',
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              for (final course in state.courses)
                CourseListItem(
                  course: course,
                  onDelete: () => context
                      .read<MyCoursesBloc>()
                      .add(MyCourseDeleted(course.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}
