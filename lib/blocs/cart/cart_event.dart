import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartLoaded extends CartEvent {
  const CartLoaded();
}

class CartQuantityChanged extends CartEvent {
  const CartQuantityChanged(this.productId, this.delta);

  final String productId;
  final int delta;

  @override
  List<Object?> get props => [productId, delta];
}

class CartItemRemoved extends CartEvent {
  const CartItemRemoved(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class CartCheckoutSubmitted extends CartEvent {
  const CartCheckoutSubmitted({this.notes});

  /// Optional note attached to the order.
  final String? notes;

  @override
  List<Object?> get props => [notes];
}
