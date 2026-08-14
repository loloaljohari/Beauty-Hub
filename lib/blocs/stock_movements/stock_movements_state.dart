import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';

enum StockMovementsStatus { initial, loading, loaded, failure }

enum StockMovementActionStatus { idle, loading, success, failure }

class StockMovementsState extends Equatable {
  const StockMovementsState({
    this.itemId = '',
    this.item,
    this.movements = const [],
    this.status = StockMovementsStatus.initial,
    this.actionStatus = StockMovementActionStatus.idle,
    this.errorMessage,
  });

  final String itemId;

  /// The material itself, so the header can show its current balance
  /// without the caller having to pass it in.
  final MaterialItemModel? item;
  final List<StockMovement> movements;
  final StockMovementsStatus status;
  final StockMovementActionStatus actionStatus;
  final String? errorMessage;

  bool get isEmpty =>
      status == StockMovementsStatus.loaded && movements.isEmpty;

  StockMovementsState copyWith({
    String? itemId,
    MaterialItemModel? item,
    List<StockMovement>? movements,
    StockMovementsStatus? status,
    StockMovementActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return StockMovementsState(
      itemId: itemId ?? this.itemId,
      item: item ?? this.item,
      movements: movements ?? this.movements,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        itemId,
        item,
        movements,
        status,
        actionStatus,
        errorMessage,
      ];
}
