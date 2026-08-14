import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/notifications/notifications_bloc.dart';
import '../../blocs/notifications/notifications_event.dart';
import '../../blocs/notifications/notifications_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/notifications_repository.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc()
        ..add(const NotificationsLoaded())
        ..add(const NotificationsMarkAsSeen()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<NotificationsBloc>()
            .add(NotificationsTabChanged(_tabController.index));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          context.l10n.notifications,
          style: AppTextStyles.h3.copyWith(
            fontSize: 16.sp(context),
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondaryGrey,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
          tabs: const [
            Tab(text: 'Alerts'),
            Tab(text: 'Notifications'),
          ],
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return TabBarView(
            controller: _tabController,
            children: [
              _AlertsTab(
                items: state.alertItems,
                status: state.status,
              ),
              _NotificationsTab(items: state.notifications),
            ],
          );
        },
      ),
    );
  }
}

// ─── Alerts Tab ───────────────────────────────────────────────────────────

class _AlertsTab extends StatelessWidget {
  const _AlertsTab({required this.items, required this.status});

  final List<MaterialItemModel> items;
  final NotificationsStatus status;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty && status == NotificationsStatus.loaded) {
      return _EmptyState(
        icon: Icons.notifications_none_outlined,
        title: context.l10n.noAlerts,
        subtitle: "We'll let you know when materials are running low.",
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
      itemBuilder: (context, index) => _AlertTile(item: items[index]),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.item});

  final MaterialItemModel item;

  @override
  Widget build(BuildContext context) {
    final isOut = item.quantity == 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceSm.h(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // أيقونة التنبيه
          Container(
            width: 40.r(context),
            height: 40.r(context),
            decoration: BoxDecoration(
              color: (isOut ? AppColors.statusDanger : AppColors.statusWarning)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOut
                  ? Icons.remove_shopping_cart_outlined
                  : Icons.warning_amber_rounded,
              size: 20.r(context),
              color: isOut ? AppColors.statusDanger : AppColors.statusWarning,
            ),
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.label.copyWith(fontSize: 14.sp(context)),
                ),
                SizedBox(height: 2.h(context)),
                Text(
                  isOut
                      ? 'This material is out of stock.'
                      : 'Only ${item.quantity} left (min: ${item.price.toStringAsFixed(0)})',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12.sp(context),
                    color: AppColors.textSecondaryGrey,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'SKU: ${item.sku}',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp(context),
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          // badge الكمية
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.spaceXs.w(context),
              vertical: 2.h(context),
            ),
            decoration: BoxDecoration(
              color: isOut
                  ? AppColors.statusDanger.withOpacity(0.1)
                  : AppColors.statusWarning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isOut ? 'Out' : '${item.quantity}',
              style: TextStyle(
                fontSize: 11.sp(context),
                fontWeight: FontWeight.w700,
                color: isOut ? AppColors.statusDanger : AppColors.statusWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Notifications Tab ────────────────────────────────────────────────────

class _NotificationsTab extends StatelessWidget {
  const _NotificationsTab({required this.items});

  final List<AppNotification> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return _EmptyState(
        icon: Icons.chat_bubble_outline,
        title: context.l10n.noNotifications,
        subtitle:
            "We'll let you know when there will be\nsomething to update you.",
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => context
          .read<NotificationsBloc>()
          .add(const NotificationsLoaded()),
      child: ListView.separated(
        padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(color: AppColors.divider),
        itemBuilder: (context, index) =>
            _NotificationTile(item: items[index]),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final AppNotification item;

  /// The server's `type` enum mapped onto an icon, so a booking and a
  /// stock warning are distinguishable at a glance.
  IconData get _icon {
    switch (item.type) {
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_reminder':
        return Icons.event_available_outlined;
      case 'employment_request':
        return Icons.work_outline;
      case 'stock_alert':
        return Icons.inventory_2_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'new_follower':
        return Icons.person_add_alt_outlined;
      case 'post_liked':
        return Icons.favorite_outline;
      case 'birthday_points':
        return Icons.card_giftcard_outlined;
      case 'payment_confirmed':
      case 'refund_issued':
        return Icons.payments_outlined;
      default:
        return Icons.notifications_none_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: AppDimens.spaceXs.h(context),
      ),
      leading: Container(
        width: 40.r(context),
        height: 40.r(context),
        decoration: BoxDecoration(
          // Unread rows carry a tinted badge; read ones stay neutral.
          color: item.isRead ? AppColors.inputBackground : AppColors.planPillBackground,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(_icon, size: 20.r(context), color: AppColors.primary),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.label.copyWith(
          fontSize: 14.sp(context),
          fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h(context)),
          Text(
            item.body,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
          if (item.createdAt.isNotEmpty) ...[
            SizedBox(height: 4.h(context)),
            Text(
              item.createdAt.split('T').first,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.sp(context),
                color: AppColors.textHint,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64.r(context), color: AppColors.divider),
          SizedBox(height: AppDimens.spaceMd.h(context)),
          Text(
            title,
            style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
          ),
          SizedBox(height: AppDimens.spaceXs.h(context)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 13.sp(context),
              color: AppColors.textSecondaryGrey,
            ),
          ),
        ],
      ),
    );
  }
}