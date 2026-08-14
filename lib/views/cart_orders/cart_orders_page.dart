import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/cart/cart_event.dart';
import '../../blocs/cart/cart_state.dart';
import '../../blocs/orders/orders_bloc.dart';
import '../../blocs/orders/orders_event.dart';
import '../../blocs/orders/orders_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/routes/route_names.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/order_model.dart';
import '../../widgets/cart_item_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/segmented_tab_bar.dart';

/// Buyer-side "My Cart & Orders" screen - matches Figma frames
/// "My Cart & Orders" (3 variants: cart / orders list / order
/// detail). This page hosts the "my cart" and "my orders" tabs;
/// tapping an order navigates to [RouteNames.orderDetailBuyer].
///
/// These orders are placed by the current expert buying from the
/// shared warehouse - status is read-only here (the warehouse/
/// seller side updates it).
class CartOrdersPage extends StatelessWidget {
  const CartOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CartBloc()..add(const CartLoaded())),
        BlocProvider(create: (_) => OrdersBloc()..add(const OrdersLoaded())),
      ],
      child: const _CartOrdersView(),
    );
  }
}

class _CartOrdersView extends StatelessWidget {
  const _CartOrdersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.myCartAndOrders,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<OrdersBloc, OrdersState>(
        builder: (context, ordersState) {
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                ),
                child: SegmentedTabBar(
                  labels: const ['my cart', 'my orders'],
                  selectedIndex: ordersState.tabIndex,
                  onChanged: (index) => context
                      .read<OrdersBloc>()
                      .add(OrdersTabChanged(index)),
                ),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              Expanded(
                child: ordersState.tabIndex == 0
                    ? const _MyCartTab()
                    : _MyOrdersTab(orders: ordersState.buyerOrders),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MyCartTab extends StatelessWidget {
  const _MyCartTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        if (state.status != CartStatus.loaded &&
            state.status != CartStatus.checkoutSuccess) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.items.isEmpty) {
          return Center(child: Text(context.l10n.cartEmpty));
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH.w(context),
                  vertical: AppDimens.spaceXs.h(context),
                ),
                children: [
                  for (final item in state.items)
                    CartItemRow(
                      item: item,
                      onIncrement: () => context
                          .read<CartBloc>()
                          .add(CartQuantityChanged(item.product.id, 1)),
                      onDecrement: () => context
                          .read<CartBloc>()
                          .add(CartQuantityChanged(item.product.id, -1)),
                      onRemove: () => context
                          .read<CartBloc>()
                          .add(CartItemRemoved(item.product.id)),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimens.screenPaddingH.w(context)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.l10n.total,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 16.sp(context),
                        ),
                      ),
                      Text(
                        state.formattedTotal,
                        style: AppTextStyles.h3.copyWith(
                          fontSize: 18.sp(context),
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimens.spaceSm.h(context)),
                  PrimaryButton(
                    label: context.l10n.checkout,
                    variant: PrimaryButtonVariant.filled,
                    onPressed: () =>
                        context.read<CartBloc>().add(const CartCheckoutSubmitted()),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MyOrdersTab extends StatelessWidget {
  const _MyOrdersTab({required this.orders});

  final List<OrderModel> orders;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(child: Text(context.l10n.noOrdersYet));
    }

    return ListView(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPaddingH.w(context),
        vertical: AppDimens.spaceXs.h(context),
      ),
      children: [
        for (final order in orders)
          _OrderSummaryCard(
            order: order,
            onTap: () => Navigator.of(context).pushNamed(
              RouteNames.orderDetailBuyer,
              arguments: order.id,
            ),
          ),
      ],
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimens.spaceSm.h(context)),
        padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius:
              BorderRadius.circular(AppDimens.postCardRadius.r(context)),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
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
                    '${order.date}  ${order.time}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12.sp(context),
                      color: AppColors.textSecondaryGrey,
                    ),
                  ),
                ],
              ),
            ),
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
