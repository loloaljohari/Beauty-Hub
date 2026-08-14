import 'package:equatable/equatable.dart';

abstract class AddProductEvent extends Equatable {
  const AddProductEvent();

  @override
  List<Object?> get props => [];
}

class AddProductFieldChanged extends AddProductEvent {
  const AddProductFieldChanged(this.key, this.value);

  /// One of: name, category, bio, price, currentStock, reorderAt.
  final String key;
  final String value;

  @override
  List<Object?> get props => [key, value];
}

class AddProductSubmitted extends AddProductEvent {
  const AddProductSubmitted();
}

class AddProductImagePicked extends AddProductEvent {
  const AddProductImagePicked(this.imagePath);

  final String imagePath;

  @override
  List<Object?> get props => [imagePath];
}

/// Opens the form. Pass a [productId] to edit, omit it to create.
class AddProductStarted extends AddProductEvent {
  const AddProductStarted({this.productId});

  final String? productId;

  @override
  List<Object?> get props => [productId];
}
