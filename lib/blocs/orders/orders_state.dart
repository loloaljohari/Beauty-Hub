import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

enum OrdersStatus { initial, loading, loaded, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.buyerOrders = const [],
    this.tabIndex = 0,
    this.status = OrdersStatus.initial,
    this.errorMessage,
  });

  /// Orders the current expert placed as a buyer from the warehouse
  /// (read-only tracking - status changes come from the seller side).
  final List<OrderModel> buyerOrders;

  /// 0 = my cart, 1 = my orders.
  final int tabIndex;
  final OrdersStatus status;
  final String? errorMessage;

  bool get isEmpty => status == OrdersStatus.loaded && buyerOrders.isEmpty;

  OrdersState copyWith({
    List<OrderModel>? buyerOrders,
    int? tabIndex,
    OrdersStatus? status,
    String? errorMessage,
  }) {
    return OrdersState(
      buyerOrders: buyerOrders ?? this.buyerOrders,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [buyerOrders, tabIndex, status, errorMessage];
}
