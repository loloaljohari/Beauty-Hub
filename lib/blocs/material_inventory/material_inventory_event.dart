import 'package:equatable/equatable.dart';

abstract class MaterialInventoryEvent extends Equatable {
  const MaterialInventoryEvent();

  @override
  List<Object?> get props => [];
}

class MaterialInventoryLoaded extends MaterialInventoryEvent {
  const MaterialInventoryLoaded();
}

class MaterialQuantityChanged extends MaterialInventoryEvent {
  const MaterialQuantityChanged(this.materialId, this.delta);

  final String materialId;
  final int delta;

  @override
  List<Object?> get props => [materialId, delta];
}

class MaterialDeleted extends MaterialInventoryEvent {
  const MaterialDeleted(this.materialId);

  final String materialId;

  @override
  List<Object?> get props => [materialId];
}
