import 'package:equatable/equatable.dart';

import '../../data/models/material_item_model.dart';

abstract class AddMaterialEvent extends Equatable {
  const AddMaterialEvent();

  @override
  List<Object?> get props => [];
}

class AddMaterialFieldChanged extends AddMaterialEvent {
  const AddMaterialFieldChanged(this.key, this.value);

  /// One of: name, category, bio, price, currentStock, peopleNeeding.
  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class AddMaterialImagePicked extends AddMaterialEvent {
  const AddMaterialImagePicked(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

class UpdateMaterialSubmitted extends AddMaterialEvent {
  final String id;
  final MaterialItemModel materialItem;
  const UpdateMaterialSubmitted({required this.id, required this.materialItem});
}
class AddMaterialSubmitted extends AddMaterialEvent {
  const AddMaterialSubmitted();
}
