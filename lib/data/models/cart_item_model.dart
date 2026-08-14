import 'package:equatable/equatable.dart';
import 'product_model.dart';

/// A single line item in the expert's cart when buying from the
/// shared warehouse marketplace.
class CartItemModel extends Equatable {
  const CartItemModel({
    required this.product,
    required this.quantity,
    this.date = '',
    this.time = '',
  });

  final ProductModel product;
  final int quantity;
  final String date;
  final String time;

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      product: product,
      quantity: quantity ?? this.quantity,
      date: date,
      time: time,
    );
  }

  @override
  List<Object?> get props => [product, quantity, date, time];
}
