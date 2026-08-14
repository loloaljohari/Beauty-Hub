import 'package:equatable/equatable.dart';

abstract class OrderDetailEvent extends Equatable {
  const OrderDetailEvent();

  @override
  List<Object?> get props => [];
}

class OrderDetailLoaded extends OrderDetailEvent {
  const OrderDetailLoaded(this.orderId);

  final String orderId;

  @override
  List<Object?> get props => [orderId];
}

/// Seller-only: marks the order as shipped (advances the timeline).
class OrderMarkedAsShipped extends OrderDetailEvent {
  const OrderMarkedAsShipped();
}

/// Seller-only: cancels the order.
class OrderDetailCancelled extends OrderDetailEvent {
  const OrderDetailCancelled();
}

/// Moves a seller order to an explicit backend status
/// (`confirmed` | `processing` | `shipped` | `delivered`).
class OrderStatusAdvanced extends OrderDetailEvent {
  const OrderStatusAdvanced(this.status);

  final String status;

  @override
  List<Object?> get props => [status];
}
