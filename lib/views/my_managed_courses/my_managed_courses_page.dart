import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/routes/route_names.dart';
import '../../widgets/state_views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/my_managed_courses/my_managed_courses_bloc.dart';
import '../../blocs/my_managed_courses/my_managed_courses_event.dart';
import '../../blocs/my_managed_courses/my_managed_courses_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../widgets/training_cards.dart';

/// "My Courses" under Training & Courses - courses the expert
/// created and teaches themselves.
class MyManagedCoursesPage extends StatelessWidget {
  const MyManagedCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MyManagedCoursesBloc()..add(const MyManagedCoursesLoaded()),
      child: const _MyManagedCoursesView(),
    );
  }
}

class _MyManagedCoursesView extends StatelessWidget {
  const _MyManagedCoursesView();

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
          heroTag: 'managed_courses_fab',
          backgroundColor: AppColors.primary,
          onPressed: () async {
            final saved =
                await Navigator.of(context).pushNamed(RouteNames.addCourse);

            if (saved == true && context.mounted) {
              context
                  .read<MyManagedCoursesBloc>()
                  .add(const MyManagedCoursesLoaded());
            }
          },
          child: const Icon(Icons.add, color: AppColors.white),
        ),
      ),
      body: BlocBuilder<MyManagedCoursesBloc, MyManagedCoursesState>(
        builder: (context, state) {
          if (state.status == MyManagedCoursesStatus.loading ||
              state.status == MyManagedCoursesStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 110);
          }

          if (state.status == MyManagedCoursesStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context
                  .read<MyManagedCoursesBloc>()
                  .add(const MyManagedCoursesLoaded()),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.school_outlined,
              title: context.l10n.noCoursesCreated,
              message: context.l10n.tapPlusToPublishCourse,
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              for (final course in state.courses)
                ManagedCourseCard(
                  course: course,
                  onEdit: () async {
                    final saved = await Navigator.of(context).pushNamed(
                      RouteNames.addCourse,
                      arguments: course.id,
                    );

                    if (saved == true && context.mounted) {
                      context
                          .read<MyManagedCoursesBloc>()
                          .add(const MyManagedCoursesLoaded());
                    }
                  },
                  onViewStudents: () => Navigator.of(context).pushNamed(
                    RouteNames.enrollments,
                    arguments: course.id,
                  ),
                  onDelete: () => context
                      .read<MyManagedCoursesBloc>()
                      .add(ManagedCourseDeleted(course.id)),
                ),
            ],
          );
        },
      ),
    );
  }
}
