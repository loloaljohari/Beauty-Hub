import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

/// Static data source for orders, covering both order flows:
/// - [OrderRole.buyerWarehouse]: orders the current expert placed
///   buying from the shared warehouse (read-only tracking; the
///   warehouse/seller controls the status).
/// - [OrderRole.sellerStore]: orders customers placed against the
///   expert's own store (the expert controls the status).
class OrdersRepository {
  const OrdersRepository();

  /// Orders placed by the expert as a buyer from the warehouse.
  List<OrderModel> getBuyerWarehouseOrders() => const [
        OrderModel(
          id: '124',
          role: OrderRole.buyerWarehouse,
          counterpartyName: 'Lojain Aljohari',
          date: '17/5/2026',
          time: '13:30 PM',
          status: OrderStatus.packed,
          items: [
            CartItemModel(
              product: ProductModel(id: 'w1', name: 'Serum', price: 5),
              quantity: 3,
              date: '17/5/2026',
              time: '13:30 PM',
            ),
          ],
          timeline: [
            OrderTimelineStep(
              status: OrderStatus.approved,
              dateLabel: '27/5/2026 | 13:30 PM',
            ),
            OrderTimelineStep(
              status: OrderStatus.packed,
              dateLabel: '28/5/2026 | 14:10 PM',
            ),
            OrderTimelineStep(status: OrderStatus.shipped, dateLabel: null),
            OrderTimelineStep(status: OrderStatus.delivered, dateLabel: null),
          ],
        ),
      ];

  /// Orders placed by customers against the expert's own store
  /// (the expert/seller manages these).
  List<OrderModel> getSellerStoreOrders() => const [
        OrderModel(
          location: 'Riyadh, Saudi Arabia',
          id: '124',
          role: OrderRole.sellerStore,
          counterpartyName: 'center Bariq',
          date: '17/5/2026',
          time: '13:30 PM',
          status: OrderStatus.approved,
          items: [
            CartItemModel(
              product: ProductModel(id: 's1', name: 'Serum', price: 5),
              quantity: 3,
              date: '17/5/2026',
              time: '13:30 PM',
            ),
            CartItemModel(
              product: ProductModel(id: 's2', name: 'Serum', price: 5),
              quantity: 3,
              date: '17/5/2026',
              time: '13:30 PM',
            ),
          ],
          timeline: [
            OrderTimelineStep(
              status: OrderStatus.approved,
              dateLabel: 'Sat,27/5/2026',
              description: 'your order has been placed',
            ),
            OrderTimelineStep(
              status: OrderStatus.packed,
              dateLabel: 'Sat,28/5/2026',
              description: 'your items has been picked up by courier partner',
            ),
            OrderTimelineStep(status: OrderStatus.shipped, dateLabel: null),
            OrderTimelineStep(status: OrderStatus.delivered, dateLabel: null),
          ],
        ),
      ];
}
