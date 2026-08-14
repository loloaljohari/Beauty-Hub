import 'package:equatable/equatable.dart';

abstract class AddOfferEvent extends Equatable {
  const AddOfferEvent();

  @override
  List<Object?> get props => [];
}

class AddOfferStarted extends AddOfferEvent {
  const AddOfferStarted();
}

class AddOfferProductSelected extends AddOfferEvent {
  const AddOfferProductSelected(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}

class AddOfferTypeChanged extends AddOfferEvent {
  const AddOfferTypeChanged(this.type);

  /// String form of [OfferType] (discountOnPrice / buyXGetY / privatePrice).
  final String type;

  @override
  List<Object?> get props => [type];
}

class AddOfferDescriptionChanged extends AddOfferEvent {
  const AddOfferDescriptionChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddOfferStartDateChanged extends AddOfferEvent {
  const AddOfferStartDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddOfferEndDateChanged extends AddOfferEvent {
  const AddOfferEndDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddOfferSubmitted extends AddOfferEvent {
  const AddOfferSubmitted();
}
