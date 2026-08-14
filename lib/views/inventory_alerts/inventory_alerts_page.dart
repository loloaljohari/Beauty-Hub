import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/inventory_alerts/inventory_alerts_bloc.dart';
import '../../blocs/inventory_alerts/inventory_alerts_event.dart';
import '../../blocs/inventory_alerts/inventory_alerts_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';
import '../../widgets/segmented_tab_bar.dart';
import '../../widgets/stat_badge_row.dart';
import '../../widgets/state_views.dart';

/// Stock alerts.
///
/// New screen covering two endpoints that had no UI:
///   `GET /expert/inventory/alerts`      - what is running out now
///   `GET /expert/inventory/smart-alert` - what tomorrow's confirmed
///                                         bookings will consume
///
/// The second is the more valuable of the two and was completely
/// unreachable: it cross-references `service_materials` against the
/// day's bookings and reports the shortfall per item, which is exactly
/// the "will I get through tomorrow" question an expert asks.
class InventoryAlertsPage extends StatelessWidget {
  const InventoryAlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          InventoryAlertsBloc()..add(const InventoryAlertsLoaded()),
      child: const _InventoryAlertsView(),
    );
  }
}

class _InventoryAlertsView extends StatelessWidget {
  const _InventoryAlertsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(
          context.l10n.stockAlerts,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<InventoryAlertsBloc, InventoryAlertsState>(
        builder: (context, state) {
          final bloc = context.read<InventoryAlertsBloc>();

          if (state.status == InventoryAlertsStatus.loading ||
              state.status == InventoryAlertsStatus.initial) {
            return const SkeletonList(itemCount: 5, itemHeight: 80);
          }

          if (state.status == InventoryAlertsStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => bloc.add(const InventoryAlertsLoaded()),
            );
          }

          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                  vertical: AppDimens.spaceMd.h(context),
                ),
                child: Column(
                  children: [
                    StatBadgeRow(
                      badges: [
                        StatBadge(
                          label: context.l10n.lowStock,
                          value: '${state.lowStock.length}',
                          color: AppColors.statusWarning,
                        ),
                        StatBadge(
                          label: context.l10n.shortages,
                          value: '${state.smartAlert?.shortagesCount ?? 0}',
                          color: AppColors.statusDanger,
                        ),
                        StatBadge(
                          label: context.l10n.bookings,
                          value: '${state.smartAlert?.bookingsCount ?? 0}',
                        ),
                      ],
                    ),
                    SizedBox(height: AppDimens.spaceMd.h(context)),
                    SegmentedTabBar(
                      labels: const ['Low stock', "Tomorrow's needs"],
                      selectedIndex: state.tabIndex,
                      onChanged: (index) =>
                          bloc.add(InventoryAlertsTabChanged(index)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.tabIndex == 0
                    ? _LowStockList(state: state)
                    : _SmartAlertList(state: state),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LowStockList extends StatelessWidget {
  const _LowStockList({required this.state});

  final InventoryAlertsState state;

  @override
  Widget build(BuildContext context) {
    if (state.isLowStockEmpty) {
      return EmptyState(
        icon: Icons.check_circle_outline,
        title: context.l10n.everythingStocked,
        message: context.l10n.noMaterialAtMinimum,
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(
        left: AppDimens.screenPaddingH.w(context),
        right: AppDimens.screenPaddingH.w(context),
        bottom: AppDimens.spaceXl.h(context),
      ),
      itemCount: state.lowStock.length,
      separatorBuilder: (_, __) => Divider(
        color: AppColors.divider,
        height: AppDimens.spaceMd.h(context),
      ),
      itemBuilder: (context, index) {
        final item = state.lowStock[index];
        return _LowStockRow(item: item);
      },
    );
  }
}

class _LowStockRow extends StatelessWidget {
  const _LowStockRow({required this.item});

  final MaterialItemModel item;

  @override
  Widget build(BuildContext context) {
    final isOut = item.quantity == 0;

    return InkWell(
      // Straight into the ledger, where the shortfall can be fixed by
      // recording a purchase.
      onTap: () => Navigator.of(context).pushNamed(
        RouteNames.stockMovements,
        arguments: item.id,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXxs.h(context)),
        child: Row(
          children: [
            Icon(
              isOut ? Icons.error_outline : Icons.warning_amber_rounded,
              color: isOut ? AppColors.statusDanger : AppColors.statusWarning,
              size: 24.r(context),
            ),
            SizedBox(width: AppDimens.spaceSm.w(context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.bodyMediumBold
                        .copyWith(fontSize: 15.sp(context)),
                  ),
                  Text(
                    isOut
                        ? 'Out of stock'
                        : '${item.quantity} left  ·  minimum '
                            '${item.min_stock.round()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textBody,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _SmartAlertList extends StatelessWidget {
  const _SmartAlertList({required this.state});

  final InventoryAlertsState state;

  @override
  Widget build(BuildContext context) {
    final alert = state.smartAlert;

    if (alert == null || alert.materials.isEmpty) {
      return EmptyState(
        icon: Icons.event_available_outlined,
        title: context.l10n.nothingToConsume,
        // The most common cause of an empty result here is not "no
        // bookings" but "no materials linked to services", so the copy
        // says so instead of leaving the user puzzled.
        message:
            context.l10n.noBookingsThatDay??
            'have no materials linked to them yet.',
      );
    }

    return ListView(
      padding: EdgeInsets.only(
        left: AppDimens.screenPaddingH.w(context),
        right: AppDimens.screenPaddingH.w(context),
        bottom: AppDimens.spaceXl.h(context),
      ),
      children: [
        Text(
          '${alert.bookingsCount} booking(s) on ${alert.date}',
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 13.sp(context),
            color: AppColors.textBody,
          ),
        ),
        SizedBox(height: AppDimens.spaceSm.h(context)),
        for (final material in alert.materials) ...[
          _SmartAlertRow(material: material),
          Divider(
            color: AppColors.divider,
            height: AppDimens.spaceMd.h(context),
          ),
        ],
      ],
    );
  }
}

class _SmartAlertRow extends StatelessWidget {
  const _SmartAlertRow({required this.material});

  final SmartAlertMaterial material;

  @override
  Widget build(BuildContext context) {
    final color =
        material.isEnough ? AppColors.statusSuccess : AppColors.statusDanger;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                material.name,
                style: AppTextStyles.bodyMediumBold
                    .copyWith(fontSize: 15.sp(context)),
              ),
              Text(
                'Needs ${_trim(material.required)}  ·  '
                'have ${_trim(material.available)}',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 12.sp(context),
                  color: AppColors.textBody,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimens.spaceXs.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            material.isEnough
                ? 'Enough'
                : 'Short ${_trim(material.shortage)}',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp(context),
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _trim(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(2);
}
