import 'package:equatable/equatable.dart';

abstract class PlanEvent extends Equatable {
  const PlanEvent();

  @override
  List<Object?> get props => [];
}

/// Loads the available plans from the repository.
class PlanLoaded extends PlanEvent {
  const PlanLoaded();
}

/// Fired when the user taps "Choose" / "Current" on a plan card.
class PlanSelected extends PlanEvent {
  const PlanSelected(this.planId);

  final String planId;

  @override
  List<Object?> get props => [planId];
}
