import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class OrdersLoaded extends OrdersEvent {
  const OrdersLoaded();
}

/// Switches between "my cart" and "my orders" top tabs on the
/// buyer-side screen.
class OrdersTabChanged extends OrdersEvent {
  const OrdersTabChanged(this.tabIndex);

  /// 0 = my cart, 1 = my orders.
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class OrderCancelled extends OrdersEvent {
  const OrderCancelled(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}
