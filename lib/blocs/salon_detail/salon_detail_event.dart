import 'package:equatable/equatable.dart';
import '../../data/models/salon_model.dart';

abstract class SalonDetailEvent extends Equatable {
  const SalonDetailEvent();

  @override
  List<Object?> get props => [];
}

class SalonDetailLoaded extends SalonDetailEvent {
  const SalonDetailLoaded(this.salonId, {this.type = SalonType.salon});

  final String salonId;

  /// The endpoint is `/discover/providers/{type}/{id}`, so the type has
  /// to travel with the id - a salon and a center can share an id.
  final SalonType type;

  @override
  List<Object?> get props => [salonId, type];
}

/// Switches between the "Info" / "Reviews" / "Posts" tabs.
class SalonDetailTabChanged extends SalonDetailEvent {
  const SalonDetailTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}

class SalonFollowToggled extends SalonDetailEvent {
  const SalonFollowToggled();
}
