import 'package:flutter/material.dart';
import '../core/utils/image_helpers.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/responsive.dart';
import '../data/models/menu_models.dart';
import '../data/models/settings_models.dart';
import '../data/models/user_model.dart';

/// Side drawer matching the Figma "menu" frame: profile header +
/// three grouped sections (Business / Growth / Account).
///
/// Wire this as a [Scaffold.endDrawer] so it opens from the right
/// edge and supports the native swipe-to-close gesture.
class SideMenu extends StatelessWidget {
  const SideMenu({
    super.key,
    required this.sections,
    required this.user,
    required this.onItemTap,
  });

  final List<MenuSectionModel> sections;
  final SettingsProfileModel? user;
  final void Function(MenuItemModel item) onItemTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: AppDimens.sideMenuWidth.w(context),
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceMd.w(context),
            vertical: AppDimens.spaceLg.h(context),
          ),
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/logo.png',
                height: 30.h(context),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: AppDimens.spaceLg.h(context)),
            if (user != null) _ProfileSummary(user: user!),
            SizedBox(height: AppDimens.spaceLg.h(context)),
            for (final section in sections) ...[
              _SectionTitle(title: section.title),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              for (final item in section.items)
                _MenuRow(item: item, onTap: () => onItemTap(item)),
              SizedBox(height: AppDimens.spaceMd.h(context)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({required this.user});

  final SettingsProfileModel user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22.r(context),
          backgroundColor: AppColors.avatarPlaceholder,
          backgroundImage: user.avatarUrl != null
              ? remoteImageProvider(user.avatarUrl)
              : null,
        ),
        SizedBox(width: AppDimens.spaceSm.w(context)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
              ),
              Text(
                user.typeOfWork,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp(context),
                  color: AppColors.textSecondaryGrey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.bodySmall.copyWith(
        fontSize: 12.sp(context),
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondaryGrey,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.onTap});

  final MenuItemModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20.r(context),
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppDimens.spaceSm.w(context)),
            Text(
              item.label,
              style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
            ),
          ],
        ),
      ),
    );
  }
}
