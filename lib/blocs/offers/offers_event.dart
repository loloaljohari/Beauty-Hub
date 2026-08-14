import 'package:equatable/equatable.dart';

abstract class OffersEvent extends Equatable {
  const OffersEvent();

  @override
  List<Object?> get props => [];
}

class OffersLoaded extends OffersEvent {
  const OffersLoaded();
}

/// Switches between Service Discounts / Products Offers / Packages /
/// Rewards.
class OffersTabChanged extends OffersEvent {
  const OffersTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class DiscountDeleted extends OffersEvent {
  const DiscountDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class OfferDeleted extends OffersEvent {
  const OfferDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class PackageDeleted extends OffersEvent {
  const PackageDeleted(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

/// Grants the 20 loyalty points the backend awards for a birthday.
class BirthdayGiftGranted extends OffersEvent {
  const BirthdayGiftGranted(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
