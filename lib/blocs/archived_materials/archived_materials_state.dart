import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';

enum ArchivedMaterialsStatus { initial, loading, loaded, failure }

class ArchivedMaterialsState extends Equatable {
  const ArchivedMaterialsState({
    this.materials = const [],
    this.status = ArchivedMaterialsStatus.initial,
    this.errorMessage,
    this.restoringId,
  });

  final List<MaterialItemModel> materials;
  final ArchivedMaterialsStatus status;
  final String? errorMessage;
  final String? restoringId; // الـ id الذي يتم استرجاعه حالياً

  ArchivedMaterialsState copyWith({
    List<MaterialItemModel>? materials,
    ArchivedMaterialsStatus? status,
    String? errorMessage,
    String? restoringId,
  }) {
    return ArchivedMaterialsState(
      materials: materials ?? this.materials,
      status: status ?? this.status,
      errorMessage: errorMessage,
      restoringId: restoringId,
    );
  }

  @override
  List<Object?> get props => [materials, status, errorMessage, restoringId];
}
