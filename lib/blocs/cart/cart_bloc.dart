import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/shop_repository.dart';
import 'cart_event.dart';
import 'cart_state.dart';

/// The expert's cart when buying from a warehouse.
///
/// Every mutation goes to `/expert/shop/cart/*` and the server returns
/// the whole cart, so the total is never recomputed locally and cannot
/// drift from what checkout will charge.
class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const CartState()) {
    on<CartLoaded>(_onLoaded);
    on<CartQuantityChanged>(_onQuantityChanged);
    on<CartItemRemoved>(_onItemRemoved);
    on<CartCheckoutSubmitted>(_onCheckoutSubmitted);
  }

  final ShopRepository _repository;

  Future<void> _onLoaded(CartLoaded event, Emitter<CartState> emit) async {
    emit(state.copyWith(status: CartStatus.loading, errorMessage: null));

    try {
      _emitCart(emit, await _repository.getCart());
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: 'Could not load your cart.',
      ));
    }
  }

  /// The stepper sends a delta; the endpoint takes an absolute
  /// quantity, and 0 removes the line.
  Future<void> _onQuantityChanged(
    CartQuantityChanged event,
    Emitter<CartState> emit,
  ) async {
    final line = state.lineFor(event.productId);
    if (line == null) return;

    final next = (line.item.quantity + event.delta).clamp(0, 999);

    try {
      _emitCart(
        emit,
        await _repository.updateCartItem(
          cartItemId: line.cartItemId,
          quantity: next,
        ),
      );
    } on ApiException catch (e) {
      // A 422 here is usually "not enough stock", which is worth saying.
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not update the quantity.'));
    }
  }

  Future<void> _onItemRemoved(
    CartItemRemoved event,
    Emitter<CartState> emit,
  ) async {
    final line = state.lineFor(event.productId);
    if (line == null) return;

    try {
      _emitCart(emit, await _repository.removeCartItem(line.cartItemId));
    } on ApiException catch (e) {
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not remove this item.'));
    }
  }

  /// POST /expert/shop/cart/checkout - creates the order and empties
  /// the cart server-side.
  Future<void> _onCheckoutSubmitted(
    CartCheckoutSubmitted event,
    Emitter<CartState> emit,
  ) async {
    if (state.items.isEmpty) return;

    // The server rejects a checkout containing an out-of-stock line, so
    // it is caught here with a clearer message.
    if (state.hasStockIssue) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage:
            'One of your items is no longer available in that quantity.',
      ));
      return;
    }

    emit(state.copyWith(status: CartStatus.loading));

    try {
      await _repository.checkout(notes: event.notes);

      emit(state.copyWith(
        lines: const [],
        total: 0,
        status: CartStatus.checkoutSuccess,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: CartStatus.failure,
        errorMessage: 'Could not place your order.',
      ));
    }
  }

  void _emitCart(Emitter<CartState> emit, CartBundle cart) {
    emit(state.copyWith(
      lines: cart.items,
      total: cart.total,
      status: CartStatus.loaded,
    ));
  }
}
