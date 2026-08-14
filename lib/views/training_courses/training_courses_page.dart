import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';

/// "Training & Courses" hub - matches Figma's central screen with 4
/// large option cards leading to separate screens. Distinct from the
/// simpler "My Courses" on the Profile tab (which lists courses the
/// expert completed before joining the app).
class TrainingCoursesPage extends StatelessWidget {
  const TrainingCoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.trainingAndCourses,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: GridView.count(
        padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
        crossAxisCount: MediaQuery.of(context).size.width >= 600 ? 4 : 2,
        mainAxisSpacing: AppDimens.spaceSm.h(context),
        crossAxisSpacing: AppDimens.spaceSm.w(context),
        childAspectRatio: 1.1,
        children: [
          _HubCard(
            icon: Icons.school_outlined,
            label: context.l10n.myCourses,
            subtitle: context.l10n.coursesYouTeach,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.myManagedCourses),
          ),
          _HubCard(
            icon: Icons.travel_explore_outlined,
            label: context.l10n.availableCourses,
            subtitle: context.l10n.browseAndEnroll,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.availableCourses),
          ),
          _HubCard(
            icon: Icons.menu_book_outlined,
            label: context.l10n.myEnrollments,
            subtitle: context.l10n.trackYourProgress,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.enrollments),
          ),
          _HubCard(
            icon: Icons.workspace_premium_outlined,
            label: context.l10n.myCertificates,
            subtitle: context.l10n.completedCourses,
            onTap: () =>
                Navigator.of(context).pushNamed(RouteNames.certificates),
          ),
        ],
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  const _HubCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36.r(context), color: AppColors.primary),
            SizedBox(height: AppDimens.spaceSm.h(context)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
            ),
            SizedBox(height: 2.h(context)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.sp(context),
                color: AppColors.textSecondaryGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
