import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';

enum InventoryAlertsStatus { initial, loading, loaded, failure }

class InventoryAlertsState extends Equatable {
  const InventoryAlertsState({
    this.lowStock = const [],
    this.smartAlert,
    this.tabIndex = 0,
    this.status = InventoryAlertsStatus.initial,
    this.errorMessage,
  });

  /// `GET /expert/inventory/alerts` - items at or under their threshold.
  final List<MaterialItemModel> lowStock;

  /// `GET /expert/inventory/smart-alert` - what the selected day's
  /// bookings will consume versus what is in stock.
  final SmartAlert? smartAlert;

  final int tabIndex;
  final InventoryAlertsStatus status;
  final String? errorMessage;

  bool get isLowStockEmpty =>
      status == InventoryAlertsStatus.loaded && lowStock.isEmpty;

  bool get isSmartAlertEmpty =>
      status == InventoryAlertsStatus.loaded &&
      (smartAlert == null || smartAlert!.materials.isEmpty);

  InventoryAlertsState copyWith({
    List<MaterialItemModel>? lowStock,
    SmartAlert? smartAlert,
    int? tabIndex,
    InventoryAlertsStatus? status,
    String? errorMessage,
  }) {
    return InventoryAlertsState(
      lowStock: lowStock ?? this.lowStock,
      smartAlert: smartAlert ?? this.smartAlert,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [lowStock, smartAlert, tabIndex, status, errorMessage];
}
