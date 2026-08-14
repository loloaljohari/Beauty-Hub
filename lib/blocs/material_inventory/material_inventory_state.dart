import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';

enum MaterialInventoryStatus { initial, loading, loaded, failure }
enum MaterialActionStatus { initial, success, failure }
class MaterialInventoryState extends Equatable {
  const MaterialInventoryState({
    this.materials = const [],
    this.itemsCount = 0,
    this.expiringSoonCount = 0,
    this.outOfStockCount = 0,
    this.status = MaterialInventoryStatus.initial,
    this.actionStatus = MaterialActionStatus.initial,
    this.errorMessage,
  });

  final List<MaterialItemModel> materials;
  final int itemsCount;
  final int expiringSoonCount;
  final int outOfStockCount;
  final MaterialInventoryStatus status;
  final MaterialActionStatus actionStatus;
  final String? errorMessage;

  bool get isEmpty =>
      status == MaterialInventoryStatus.loaded && materials.isEmpty;

  MaterialInventoryState copyWith({
    List<MaterialItemModel>? materials,
    int? itemsCount,
    int? expiringSoonCount,
    int? outOfStockCount,
    MaterialInventoryStatus? status,
    MaterialActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return MaterialInventoryState(
      materials: materials ?? this.materials,
      itemsCount: itemsCount ?? this.itemsCount,
      expiringSoonCount: expiringSoonCount ?? this.expiringSoonCount,
      outOfStockCount: outOfStockCount ?? this.outOfStockCount,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        materials,
        itemsCount,
        expiringSoonCount,
        outOfStockCount,
        status,
        actionStatus,
        errorMessage,
      ];
}
