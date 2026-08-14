import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/store_metric_model.dart';
import '../../data/repositories/shop_repository.dart';
import 'my_store_event.dart';
import 'my_store_state.dart';

class MyStoreBloc extends Bloc<MyStoreEvent, MyStoreState> {
  MyStoreBloc({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const MyStoreState()) {
    on<MyStoreLoaded>(_onLoaded);
    on<MyStoreTabChanged>(_onTabChanged);
    on<MyStoreSearchChanged>(_onSearchChanged);
    on<MyStoreFavoriteToggled>(_onFavoriteToggled);
    on<MyStoreAddToCart>(_onAddToCart);
    on<MyStoreProductDeleted>(_onProductDeleted);
  }

  final ShopRepository _repository;

  /// Two independent lists: the warehouse catalogue the expert buys
  /// from (`/shop/products`) and their own storefront
  /// (`/store/products`).
  Future<void> _onLoaded(
    MyStoreLoaded event,
    Emitter<MyStoreState> emit,
  ) async {
    emit(state.copyWith(status: MyStoreStatus.loading, errorMessage: null));

    try {
      final warehouse = await _repository.getWarehouseProducts(
        query: state.searchQuery,
      );

      final mine = await _repository.getStoreProducts();
      final orders = await _repository.getStoreOrders();

      // The header metrics used to be three hardcoded numbers. They are
      // derived from the two lists the screen already has.
      final revenue = orders.fold<double>(0, (sum, o) => sum + o.total);

      emit(
        state.copyWith(
          warehouseProducts: warehouse,
          myStoreProducts: mine,
          metrics: [
            StoreMetricModel(label: 'Products', value: '${mine.length}', icon: Icons.storefront_outlined, accentColor: const Color(0xFF4CAF50)),
            StoreMetricModel(
              label: 'Revenue',
              value: '\$${revenue.toStringAsFixed(0)}',
              icon: (Icons.monetization_on_outlined),
              accentColor: const Color(0xFF2196F3),
            ),
            StoreMetricModel(label: 'Orders', value: '${orders.length}', icon: (Icons.shopping_cart_outlined), accentColor: const Color(0xFFFFC107)),
      
          ],
          status: MyStoreStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MyStoreStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: MyStoreStatus.failure,
        errorMessage: 'Could not load your store.',
      ));
    }
  }

  void _onTabChanged(MyStoreTabChanged event, Emitter<MyStoreState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  /// The warehouse search runs server-side, so changing it refetches.
  void _onSearchChanged(
    MyStoreSearchChanged event,
    Emitter<MyStoreState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  /// Favourites have no table for a provider-as-buyer, so this stays
  /// local to the session rather than pretending to persist.
  void _onFavoriteToggled(
    MyStoreFavoriteToggled event,
    Emitter<MyStoreState> emit,
  ) {
    emit(state.copyWith(
      warehouseProducts: state.warehouseProducts
          .map((p) => p.id == event.productId
              ? p.copyWith(isFavorite: !p.isFavorite)
              : p)
          .toList(),
    ));
  }

  /// POST /expert/shop/cart/items - real now; this used to be a TODO,
  /// so the cart button did nothing at all.
  Future<void> _onAddToCart(
    MyStoreAddToCart event,
    Emitter<MyStoreState> emit,
  ) async {
    emit(state.copyWith(actionStatus: MyStoreActionStatus.loading));

    try {
      final cart = await _repository.addToCart(
        productId: event.productId,
        quantity: event.quantity,
      );

      emit(state.copyWith(
        cartCount: cart.items.length,
        actionStatus: MyStoreActionStatus.addedToCart,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: MyStoreActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: MyStoreActionStatus.failure,
        errorMessage: 'Could not add this to your cart.',
      ));
    }
  }

  /// DELETE /expert/store/products/{id} - the server archives rather
  /// than deletes, so buyers' order history stays intact.
  Future<void> _onProductDeleted(
    MyStoreProductDeleted event,
    Emitter<MyStoreState> emit,
  ) async {
    final previous = state.myStoreProducts;

    emit(state.copyWith(
      myStoreProducts:
          previous.where((p) => p.id != event.productId).toList(),
    ));

    try {
      await _repository.deleteStoreProduct(event.productId);
      emit(state.copyWith(actionStatus: MyStoreActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        myStoreProducts: previous,
        actionStatus: MyStoreActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        myStoreProducts: previous,
        actionStatus: MyStoreActionStatus.failure,
        errorMessage: 'Could not delete this product.',
      ));
    }
  }
}
