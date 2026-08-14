import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

/// Status of an order as it moves through fulfillment.
enum OrderStatus { approved, packed, shipped, delivered, cancelled }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.approved:
        return 'Approved';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// A single milestone in an order's status timeline
/// (e.g. "Approved - 27/5/2026 | 13:30 PM").
class OrderTimelineStep extends Equatable {
  const OrderTimelineStep({
    required this.status,
    this.dateLabel,
    this.description,
  });

  final OrderStatus status;

  /// Null when this step hasn't happened yet (shown as "-").
  final String? dateLabel;

  /// Optional extra description, e.g. "your order has been placed".
  final String? description;

  bool get isCompleted => dateLabel != null;

  @override
  List<Object?> get props => [status, dateLabel, description];
}

/// Distinguishes which order flow this order belongs to:
/// - [buyerWarehouse]: the expert buying stock from the shared
///   warehouse (read-only tracking; the warehouse/seller updates status).
/// - [sellerStore]: a customer's order placed against the expert's
///   own store (the expert controls/updates the status).
enum OrderRole { buyerWarehouse, sellerStore }

class OrderModel extends Equatable {
  const OrderModel( {
    this.location='',
    required this.id,
    required this.role,
    required this.items,
    required this.date,
    required this.time,
    required this.timeline,
    this.counterpartyName = '',
    this.status = OrderStatus.approved,
    this.serverTotal,
  });

  final String id;
  final OrderRole role;
  final List<CartItemModel> items;
  final String date;
  final String time;
  final List<OrderTimelineStep> timeline;
  final String location;

  /// For [OrderRole.buyerWarehouse]: the warehouse/salon name selling
  /// the goods. For [OrderRole.sellerStore]: the customer's name.
  final String counterpartyName;

  final OrderStatus status;

  /// Total as the server computed it.
  ///
  /// Needed because an order can span two sellers: the store endpoints
  /// return a total scoped to the caller's own lines, which is not the
  /// same as summing whatever items happen to be loaded here.
  final double? serverTotal;

  double get total =>
      serverTotal ?? items.fold(0, (sum, item) => sum + item.subtotal);

  String get formattedTotal => '\$${total.toStringAsFixed(0)}';

  OrderModel copyWith({
    OrderStatus? status,
    List<OrderTimelineStep>? timeline,
  }) {
    return OrderModel(
      id: id,
      role: role,
      items: items,
      date: date,
      time: time,
      timeline: timeline ?? this.timeline,
      counterpartyName: counterpartyName,
      serverTotal: serverTotal,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        role,
        items,
        date,
        time,
        timeline,
        counterpartyName,
        status,
        serverTotal,
      ];
}
