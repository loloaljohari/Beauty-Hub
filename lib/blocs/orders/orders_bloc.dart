import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/shop_repository.dart';
import 'orders_event.dart';
import 'orders_state.dart';

/// Orders the expert PLACED as a buyer (`/expert/shop/orders`).
///
/// Status here is read-only from the expert's side - the warehouse
/// moves it along - so the only action is cancelling, and only while
/// the order is still pending or confirmed.
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const OrdersState()) {
    on<OrdersLoaded>(_onLoaded);
    on<OrdersTabChanged>(_onTabChanged);
    on<OrderCancelled>(_onCancelled);
  }

  final ShopRepository _repository;

  Future<void> _onLoaded(
    OrdersLoaded event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersStatus.loading, errorMessage: null));

    try {
      emit(state.copyWith(
        buyerOrders: await _repository.getMyOrders(),
        status: OrdersStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: OrdersStatus.failure,
        errorMessage: 'Could not load your orders.',
      ));
    }
  }

  void _onTabChanged(OrdersTabChanged event, Emitter<OrdersState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  /// POST /expert/shop/orders/{id}/cancel
  ///
  /// Previously this only dropped the row from the in-memory list, so
  /// the order reappeared on the next open.
  Future<void> _onCancelled(
    OrderCancelled event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _repository.cancelMyOrder(event.orderId);

      emit(state.copyWith(
        buyerOrders: await _repository.getMyOrders(),
        status: OrdersStatus.loaded,
      ));
    } on ApiException catch (e) {
      // The server refuses to cancel a shipped order, and says so.
      emit(state.copyWith(errorMessage: e.message));
    } catch (_) {
      emit(state.copyWith(errorMessage: 'Could not cancel this order.'));
    }
  }
}
