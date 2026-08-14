import 'package:equatable/equatable.dart';

abstract class AddDiscountEvent extends Equatable {
  const AddDiscountEvent();

  @override
  List<Object?> get props => [];
}

class AddDiscountStarted extends AddDiscountEvent {
  const AddDiscountStarted();
}

class AddDiscountServiceSelected extends AddDiscountEvent {
  const AddDiscountServiceSelected(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

class AddDiscountPercentageChanged extends AddDiscountEvent {
  const AddDiscountPercentageChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddDiscountStartDateChanged extends AddDiscountEvent {
  const AddDiscountStartDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddDiscountEndDateChanged extends AddDiscountEvent {
  const AddDiscountEndDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddDiscountSubmitted extends AddDiscountEvent {
  const AddDiscountSubmitted();
}
