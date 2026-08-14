import 'package:equatable/equatable.dart';
import '../../data/models/order_model.dart';

enum OrderDetailStatus { initial, loading, loaded, failure }

enum OrderActionStatus { idle, loading, success, failure }

class OrderDetailState extends Equatable {
  const OrderDetailState({
    this.order,
    this.status = OrderDetailStatus.initial,
    this.actionStatus = OrderActionStatus.idle,
    this.errorMessage,
  });

  final OrderModel? order;
  final OrderDetailStatus status;
  final OrderActionStatus actionStatus;
  final String? errorMessage;

  OrderDetailState copyWith({
    OrderModel? order,
    OrderDetailStatus? status,
    OrderActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return OrderDetailState(
      order: order ?? this.order,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [order, status, actionStatus, errorMessage];
}
