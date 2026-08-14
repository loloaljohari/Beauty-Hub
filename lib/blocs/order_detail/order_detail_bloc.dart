import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/shop_repository.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

/// One order's detail, for both directions.
///
///   [OrderRole.buyerWarehouse] - `/expert/shop/orders/{id}`,
///       read-only apart from cancelling before it ships.
///   [OrderRole.sellerStore]    - `/expert/store/orders/{id}`,
///       where the expert advances the status.
///
/// The status vocabulary is the server's, not the app's enum: the
/// backend only accepts forward moves along
/// pending -> confirmed -> processing -> shipped -> delivered, plus a
/// cancel before shipping. Anything else comes back as a 422.
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  OrderDetailBloc({
    required this.role,
    ShopRepository? repository,
  })  : _repository = repository ?? const ShopRepository(),
        super(const OrderDetailState()) {
    on<OrderDetailLoaded>(_onLoaded);
    on<OrderMarkedAsShipped>(_onMarkedAsShipped);
    on<OrderDetailCancelled>(_onCancelled);
    on<OrderStatusAdvanced>(_onStatusAdvanced);
  }

  final OrderRole role;
  final ShopRepository _repository;

  Future<void> _onLoaded(
    OrderDetailLoaded event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: OrderDetailStatus.loading,
      errorMessage: null,
    ));

    try {
      final order = role == OrderRole.buyerWarehouse
          ? await _repository.getMyOrder(event.orderId)
          : await _repository.getStoreOrder(event.orderId);

      emit(state.copyWith(order: order, status: OrderDetailStatus.loaded));
    } on ApiException catch (e) {
      // Falling back to "the first order in the list" (as before) would
      // show somebody else's order, which is worse than an error.
      emit(state.copyWith(
        status: OrderDetailStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: OrderDetailStatus.failure,
        errorMessage: 'Could not load this order.',
      ));
    }
  }

  Future<void> _onMarkedAsShipped(
    OrderMarkedAsShipped event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (role != OrderRole.sellerStore) return;
    await _setStatus('shipped', emit);
  }

  Future<void> _onStatusAdvanced(
    OrderStatusAdvanced event,
    Emitter<OrderDetailState> emit,
  ) async {
    if (role != OrderRole.sellerStore) return;
    await _setStatus(event.status, emit);
  }

  /// Cancelling means different endpoints on each side: the buyer calls
  /// their own cancel route, the seller sets the status.
  Future<void> _onCancelled(
    OrderDetailCancelled event,
    Emitter<OrderDetailState> emit,
  ) async {
    final order = state.order;
    if (order == null) return;

    emit(state.copyWith(actionStatus: OrderActionStatus.loading));

    try {
      final updated = role == OrderRole.buyerWarehouse
          ? await _repository.cancelMyOrder(order.id)
          : await _repository.updateStoreOrderStatus(
              orderId: order.id,
              status: 'cancelled',
            );

      emit(state.copyWith(
        order: updated,
        actionStatus: OrderActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        errorMessage: 'Could not cancel this order.',
      ));
    }
  }

  Future<void> _setStatus(
    String status,
    Emitter<OrderDetailState> emit,
  ) async {
    final order = state.order;
    if (order == null) return;

    emit(state.copyWith(actionStatus: OrderActionStatus.loading));

    try {
      final updated = await _repository.updateStoreOrderStatus(
        orderId: order.id,
        status: status,
      );

      emit(state.copyWith(
        order: updated,
        actionStatus: OrderActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: OrderActionStatus.failure,
        errorMessage: 'Could not update this order.',
      ));
    }
  }
}
