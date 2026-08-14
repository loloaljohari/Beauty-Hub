import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/shop_repository.dart';

enum ProductDetailStatus { initial, loading, loaded, failure }

enum AddToCartStatus { idle, adding, added, failure }

class ProductDetailState {
  const ProductDetailState({
    this.detail,
    this.quantity = 1,
    this.status = ProductDetailStatus.initial,
    this.cartStatus = AddToCartStatus.idle,
    this.errorMessage,
  });

  final ProductDetail? detail;
  final int quantity;
  final ProductDetailStatus status;
  final AddToCartStatus cartStatus;
  final String? errorMessage;

  double get unitPrice => detail?.product.price ?? 0;

  double get totalPrice => unitPrice * quantity;

  /// Every image the product has, main photo first, so the carousel
  /// still works for a product with a single picture.
  List<String> get images {
    final gallery = <String>[];
    final main = detail?.product.imageUrl ?? '';

    if (main.isNotEmpty) gallery.add(main);
    for (final url in detail?.images ?? const <String>[]) {
      if (!gallery.contains(url)) gallery.add(url);
    }

    return gallery;
  }

  ProductDetailState copyWith({
    ProductDetail? detail,
    int? quantity,
    ProductDetailStatus? status,
    AddToCartStatus? cartStatus,
    String? errorMessage,
  }) {
    return ProductDetailState(
      detail: detail ?? this.detail,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      cartStatus: cartStatus ?? this.cartStatus,
      errorMessage: errorMessage,
    );
  }
}

/// One warehouse product, with the quantity stepper and add-to-cart.
///
/// Backs `GET /expert/shop/products/{id}` and
/// `POST /expert/shop/cart/items` - the screen previously showed two
/// Unsplash photos, a hardcoded price of 15 and a "Book Now" button
/// that did nothing.
class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const ProductDetailState());

  final ShopRepository _repository;

  Future<void> load(Object productId) async {
    emit(state.copyWith(
      status: ProductDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(state.copyWith(
        detail: await _repository.getWarehouseProduct(productId),
        status: ProductDetailStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ProductDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ProductDetailStatus.failure,
        errorMessage: 'Could not load this product.',
      ));
    }
  }

  /// Capped at the seller's stock so checkout cannot fail later for a
  /// quantity the buyer was allowed to pick here.
  void changeQuantity(int delta) {
    final stock = state.detail?.product.stock ?? 999;
    final next = (state.quantity + delta).clamp(1, stock < 1 ? 1 : stock);
    emit(state.copyWith(quantity: next));
  }

  Future<void> addToCart() async {
    final product = state.detail?.product;
    if (product == null) return;

    emit(state.copyWith(cartStatus: AddToCartStatus.adding));

    try {
      await _repository.addToCart(
        productId: product.id,
        quantity: state.quantity,
      );

      emit(state.copyWith(cartStatus: AddToCartStatus.added));
    } on ApiException catch (e) {
      emit(state.copyWith(
        cartStatus: AddToCartStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        cartStatus: AddToCartStatus.failure,
        errorMessage: 'Could not add this to your cart.',
      ));
    }
  }
}
