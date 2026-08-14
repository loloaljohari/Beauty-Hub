import 'package:equatable/equatable.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/repositories/shop_repository.dart';

enum CartStatus { initial, loading, loaded, checkoutSuccess, failure }

class CartState extends Equatable {
  const CartState({
    this.lines = const [],
    this.total = 0,
    this.status = CartStatus.initial,
    this.errorMessage,
  });

  /// Server-side cart lines. Each carries its own `cartItemId`, which
  /// is what the update and remove endpoints key on - not the product
  /// id, since the same product can only appear once but the row id is
  /// what the API expects.
  final List<CartLine> lines;

  /// Total as the server computed it, not a local sum.
  final double total;

  final CartStatus status;
  final String? errorMessage;

  /// Kept so existing widgets that iterate `state.items` still work.
  List<CartItemModel> get items =>
      lines.map((line) => line.item).toList();

  bool get isEmpty => status == CartStatus.loaded && lines.isEmpty;

  /// True when a line's quantity now exceeds the seller's stock.
  bool get hasStockIssue => lines.any((line) => !line.inStock);

  CartLine? lineFor(String productId) {
    for (final line in lines) {
      if (line.item.product.id == productId) return line;
    }
    return null;
  }

  String get formattedTotal => '\$${total.toStringAsFixed(0)}';

  CartState copyWith({
    List<CartLine>? lines,
    double? total,
    CartStatus? status,
    String? errorMessage,
  }) {
    return CartState(
      lines: lines ?? this.lines,
      total: total ?? this.total,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [lines, total, status, errorMessage];
}
