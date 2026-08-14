import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/shop_repository.dart';

enum StoreOrdersStatus { initial, loading, loaded, failure }

class StoreOrdersState {
  const StoreOrdersState({
    this.orders = const [],
    this.status = StoreOrdersStatus.initial,
    this.errorMessage,
  });

  final List<OrderModel> orders;
  final StoreOrdersStatus status;
  final String? errorMessage;

  bool get isEmpty => status == StoreOrdersStatus.loaded && orders.isEmpty;

  StoreOrdersState copyWith({
    List<OrderModel>? orders,
    StoreOrdersStatus? status,
    String? errorMessage,
  }) {
    return StoreOrdersState(
      orders: orders ?? this.orders,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

/// Customer orders placed against the expert's own storefront
/// (`GET /expert/store/orders`).
///
/// A Cubit rather than a Bloc: the screen only ever loads and reloads,
/// so events would be ceremony without benefit.
///
/// Note the seller-scoped totals - an order can contain items from two
/// sellers, and the endpoint returns only this expert's lines with a
/// total computed from them.
class StoreOrdersCubit extends Cubit<StoreOrdersState> {
  StoreOrdersCubit({ShopRepository? repository})
      : _repository = repository ?? const ShopRepository(),
        super(const StoreOrdersState());

  final ShopRepository _repository;

  Future<void> load({String? status}) async {
    emit(state.copyWith(
      status: StoreOrdersStatus.loading,
      errorMessage: null,
    ));

    try {
      emit(state.copyWith(
        orders: await _repository.getStoreOrders(status: status),
        status: StoreOrdersStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: StoreOrdersStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StoreOrdersStatus.failure,
        errorMessage: 'Could not load your store orders.',
      ));
    }
  }
}
