import 'package:equatable/equatable.dart';

abstract class MyStoreEvent extends Equatable {
  const MyStoreEvent();

  @override
  List<Object?> get props => [];
}

class MyStoreLoaded extends MyStoreEvent {
  const MyStoreLoaded();
}

/// Switches between the "Buy from warehouse" and "My Store" top tabs.
class MyStoreTabChanged extends MyStoreEvent {
  const MyStoreTabChanged(this.tabIndex);

  /// 0 = Buy from warehouse, 1 = My Store.
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class MyStoreSearchChanged extends MyStoreEvent {
  const MyStoreSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

/// Fired when the user taps the heart icon on a warehouse product.
class MyStoreFavoriteToggled extends MyStoreEvent {
  const MyStoreFavoriteToggled(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

/// Fired when the user taps the cart icon on a warehouse product.
class MyStoreAddToCart extends MyStoreEvent {
  const MyStoreAddToCart(this.productId, {this.quantity = 1});

  final String productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

/// Archives one of the expert's own products.
class MyStoreProductDeleted extends MyStoreEvent {
  const MyStoreProductDeleted(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
