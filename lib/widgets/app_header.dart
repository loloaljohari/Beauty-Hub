import 'package:beautyhup/blocs/notifications/notifications_state.dart';
import '../core/localization/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/notifications/notifications_bloc.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_dimens.dart';
import '../core/constants/app_text_styles.dart';
import '../core/routes/route_names.dart';
import '../core/utils/responsive.dart';

/// Shared top header used on Home, Warehouse, Reservations, and
/// Chats screens: notification bell, centered "Beaut Hub" logo,
/// and a menu button.
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AppHeader({
    super.key,
    this.onNotificationTap,
    this.onMenuTap,
    this.hasUnreadNotification = false,
    this.mystore = false,
    this.rev = false,
    this.prof = false,
    this.chat = false,
  });

  final VoidCallback? onNotificationTap;
  final VoidCallback? onMenuTap;
  final bool hasUnreadNotification;
  final bool mystore;
  final bool rev;
  final bool prof;
  final bool chat;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceSm.h(context),
      ),
      child: Row(
        children: [
          prof
              ? _IconBadgeButton(
                  icon: Icons.add,
                  showBadge: hasUnreadNotification,
                  onTap: onNotificationTap,
                )
              : mystore
                  ? _IconBadgeButton(
                      icon: Icons.shopping_cart_outlined,
                      showBadge: hasUnreadNotification,
                      onTap: onNotificationTap,
                    )
                  : BlocBuilder<NotificationsBloc, NotificationsState>(
                      builder: (context, state) {
                        return _IconBadgeButton(
                          icon: Icons.notifications_outlined,
                          showBadge: state.showBadge,
                          onTap: () => Navigator.of(context)
                              .pushNamed(RouteNames.notifications),
                        );
                      },
                    ),
          Expanded(
            child: rev
                ? Center(
                    child: Text(
                      context.l10n.reservations,
                      style: AppTextStyles.h3,
                    ),
                  )
                : chat
                    ? Center(
                        child: Text(
                          context.l10n.chats,
                          style: AppTextStyles.h3,
                        ),
                      )
                    : prof
                        ? Center(
                            child: Text(
                              context.l10n.profile,
                              style: AppTextStyles.h3,
                            ),
                          )
                        : mystore
                            ? Center(
                                child: Text(
                                  context.l10n.store,
                                  style: AppTextStyles.h3,
                                ),
                              )
                            : Image.asset(
                                'assets/images/logo.png',
                                height: 24.h(context),
                                fit: BoxFit.contain,
                              ),
          ),
          _IconBadgeButton(
            icon: Icons.menu_rounded,
            showBadge: false,
            onTap: onMenuTap,
          ),
        ],
      ),
    );
  }
}

class _IconBadgeButton extends StatelessWidget {
  const _IconBadgeButton({
    required this.icon,
    required this.showBadge,
    this.onTap,
  });

  final IconData icon;
  final bool showBadge;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.all(AppDimens.spaceXs.r(context)),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 30.r(context), color: AppColors.textPrimary),
            if (showBadge)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
