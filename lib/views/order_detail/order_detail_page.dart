import 'package:flutter/material.dart';
import '../../core/localization/l10n/app_localizations.dart';
import '../../widgets/state_views.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/order_detail/order_detail_bloc.dart';
import '../../blocs/order_detail/order_detail_event.dart';
import '../../blocs/order_detail/order_detail_state.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/order_model.dart';
import '../../widgets/order_timeline.dart';
import '../../widgets/primary_button.dart';

/// "Detail of order" screen - matches Figma frames "Detail of order"
/// / "Order Status". Two modes controlled by [role]:
/// - [OrderRole.buyerWarehouse]: read-only tracking (expert buying
///   from the warehouse; the seller updates the status elsewhere).
/// - [OrderRole.sellerStore]: the expert manages a customer's order
///   against their own store, with "Mark as shipped" / "Cancel
///   order" actions.
class OrderDetailPage extends StatelessWidget {
  const OrderDetailPage({
    super.key,
    required this.orderId,
    required this.role,
  });

  final String orderId;
  final OrderRole role;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          OrderDetailBloc(role: role)..add(OrderDetailLoaded(orderId)),
      child: const _OrderDetailView(),
    );
  }
}

class _OrderDetailView extends StatelessWidget {
  const _OrderDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          context.l10n.orderDetail,
          style: AppTextStyles.h3.copyWith(fontSize: 18.sp(context)),
        ),
      ),
      body: BlocBuilder<OrderDetailBloc, OrderDetailState>(
        builder: (context, state) {
          if (state.status != OrderDetailStatus.loaded ||
              state.order == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = state.order!;
          final bloc = context.read<OrderDetailBloc>();
          final isSeller = bloc.role == OrderRole.sellerStore;

          return ListView(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimens.screenPaddingH.w(context),
              vertical: AppDimens.spaceMd.h(context),
            ),
            children: [
              _OrderHeader(order: order, isSeller: isSeller),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              Text(
                context.l10n.items,
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceXs.h(context)),
              for (final item in order.items) _OrderItemRow(item: item),
              SizedBox(height: AppDimens.spaceLg.h(context)),
              Text(
                context.l10n.orderStatus,
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
              ),
              SizedBox(height: AppDimens.spaceSm.h(context)),
              OrderTimeline(steps: order.timeline),
              if (isSeller && order.status != OrderStatus.cancelled) ...[
                SizedBox(height: AppDimens.spaceMd.h(context)),
                PrimaryButton(
                  label: context.l10n.markAsShipped,
                  variant: PrimaryButtonVariant.filled,
                  onPressed: order.status == OrderStatus.shipped ||
                          order.status == OrderStatus.delivered
                      ? null
                      : () => bloc.add(const OrderMarkedAsShipped()),
                ),
                SizedBox(height: AppDimens.spaceSm.h(context)),
                OutlinedButton(
                  onPressed: () => bloc.add(const OrderDetailCancelled()),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    minimumSize: Size(double.infinity, 50.h(context)),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.buttonRadius),
                    ),
                  ),
                  child: Text(context.l10n.cancelOrder),
                ),
              ] else if (!isSeller) ...[
                SizedBox(height: AppDimens.spaceMd.h(context)),
                Container(
                  padding: EdgeInsets.all(AppDimens.spaceSm.r(context)),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 18.r(context),
                        color: AppColors.textSecondaryGrey,
                      ),
                      SizedBox(width: AppDimens.spaceXs.w(context)),
                      Expanded(
                        child: Text(
                          context.l10n.sellerManagesStatus??
                          'will appear here automatically.',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp(context),
                            color: AppColors.textSecondaryGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order, required this.isSeller});

  final OrderModel order;
  final bool isSeller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.spaceMd.r(context)),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order #${order.id}',
              style: AppTextStyles.h3.copyWith(fontSize: 16.sp(context)),
            ),
            SizedBox(height: AppDimens.spaceXxs.h(context)),
            Text(
              isSeller
                  ? 'Customer: ${order.counterpartyName}'
                  : order.counterpartyName,
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
            ),
              Text(
                      "Location: ${order.location}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 13.sp(context),
                        color: AppColors.textBody,
                      ),
                    ),
            Text(
              '${order.date}  ${order.time}',
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 12.sp(context),
                color: AppColors.textSecondaryGrey,
              ),
            ),
            SizedBox(height: AppDimens.spaceXs.h(context)),
            Text(
              'Total: ${order.formattedTotal}',
              style: AppTextStyles.label.copyWith(
                fontSize: 14.sp(context),
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimens.spaceXs.h(context)),
      child: Row(
        children: [
          CardThumbnail(
            imageUrl: item.product.imageUrl,
            size: 40.r(context),
            radius: 8,
          ),
          SizedBox(width: AppDimens.spaceSm.w(context)),
          Expanded(
            child: Text(
              '${item.product.name} x${item.quantity}',
              style:
                  AppTextStyles.bodyMedium.copyWith(fontSize: 13.sp(context)),
            ),
          ),
          Text(
            '\$${item.subtotal.toStringAsFixed(0)}',
            style: AppTextStyles.label.copyWith(fontSize: 13.sp(context)),
          ),
        ],
      ),
    );
  }
}