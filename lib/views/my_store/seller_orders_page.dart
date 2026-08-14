import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/order_model.dart';
import '../../blocs/store_orders/store_orders_cubit.dart';
import '../../widgets/state_views.dart';

/// Lists the customer orders placed against the expert's own store
/// (seller side - matches the Figma "Detail of order" merchant
/// view's parent list). Tapping an order opens
/// [RouteNames.orderDetailSeller] where the expert can update its
/// status.
class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StoreOrdersCubit()..load(),
      child: const _SellerOrdersView(),
    );
  }
}

class _SellerOrdersView extends StatelessWidget {
  const _SellerOrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        // Embedded in the Reservations "Products" tab, so AppBar's
        // automatic back arrow would pop the whole tab shell.
        automaticallyImplyLeading: false,
        title: Text(
          context.l10n.storeOrders,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<StoreOrdersCubit, StoreOrdersState>(
        builder: (context, state) {
          if (state.status == StoreOrdersStatus.loading ||
              state.status == StoreOrdersStatus.initial) {
            return const SkeletonList(itemCount: 4, itemHeight: 90);
          }

          if (state.status == StoreOrdersStatus.failure) {
            return ErrorState(
              message: state.errorMessage,
              onRetry: () => context.read<StoreOrdersCubit>().load(),
            );
          }

          if (state.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: context.l10n.noCustomerOrders,
              message:
                  context.l10n.storeOrderHint??
                  'here so you can pack and ship it.',
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => context.read<StoreOrdersCubit>().load(),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimens.screenPaddingH.w(context),
                vertical: AppDimens.spaceMd.h(context),
              ),
              children: [
                for (final order in state.orders)
                  _SellerOrderCard(order: order),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SellerOrderCard extends StatelessWidget {
  const _SellerOrderCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          RouteNames.orderDetailSeller,
          arguments: order.id,
        );
        // The status may have advanced while the detail was open.
        if (context.mounted) context.read<StoreOrdersCubit>().load();
      },
      child: Container(
        height: 90,
        margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
        padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppDimens.postCardRadius.r(context)),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id}',
                    style:
                        AppTextStyles.label.copyWith(fontSize: 15.sp(context)),
                  ),
                  Text(
                    'Customer: ${order.counterpartyName}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                  // Only shown when there is one: a buyer can check out
                  // without an address, and a bare "Location:" label
                  // reads as a bug rather than an absence.
                  if (order.location.isNotEmpty)
                    Text(
                      'Location:  ${order.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13.sp(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 50.w(context)),
            Text(
              order.status.label,
              style: AppTextStyles.label.copyWith(
                fontSize: 13.sp(context),
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: AppDimens.spaceSm.w(context)),
            Text(
              order.formattedTotal,
              style: AppTextStyles.h3.copyWith(fontSize: 14.sp(context)),
            ),
          ],
        ),
      ),
    );
  }
}