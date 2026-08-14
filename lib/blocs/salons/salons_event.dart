import 'package:equatable/equatable.dart';

abstract class SalonsEvent extends Equatable {
  const SalonsEvent();

  @override
  List<Object?> get props => [];
}

class SalonsLoaded extends SalonsEvent {
  const SalonsLoaded();
}

/// Switches between the "Salons" and "Centers" top tabs.
class SalonsTabChanged extends SalonsEvent {
  const SalonsTabChanged(this.tabIndex);

  /// 0 = Salons, 1 = Centers.
  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class SalonsCityChanged extends SalonsEvent {
  const SalonsCityChanged(this.city);

  final String city;

  @override
  List<Object?> get props => [city];
}

/// Follows or unfollows a provider from the list card.
class SalonFollowRequested extends SalonsEvent {
  const SalonFollowRequested(this.salonId);

  final String salonId;

  @override
  List<Object?> get props => [salonId];
}
