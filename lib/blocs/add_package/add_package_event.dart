import 'package:equatable/equatable.dart';

abstract class AddPackageEvent extends Equatable {
  const AddPackageEvent();

  @override
  List<Object?> get props => [];
}

class AddPackageStarted extends AddPackageEvent {
  const AddPackageStarted({this.packageId});

  /// Null creates a new bundle; set loads an existing one for editing.
  final String? packageId;

  @override
  List<Object?> get props => [packageId];
}

class AddPackageNameChanged extends AddPackageEvent {
  const AddPackageNameChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddPackageBioChanged extends AddPackageEvent {
  const AddPackageBioChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

/// Toggles a product or service (by id) in/out of the package.
class AddPackageItemToggled extends AddPackageEvent {
  const AddPackageItemToggled(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

class AddPackagePriceChanged extends AddPackageEvent {
  const AddPackagePriceChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddPackageDiscountChanged extends AddPackageEvent {
  const AddPackageDiscountChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddPackageStartDateChanged extends AddPackageEvent {
  const AddPackageStartDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddPackageEndDateChanged extends AddPackageEvent {
  const AddPackageEndDateChanged(this.value);

  final String value;

  @override
  List<Object?> get props => [value];
}

class AddPackageSubmitted extends AddPackageEvent {
  const AddPackageSubmitted();
}
