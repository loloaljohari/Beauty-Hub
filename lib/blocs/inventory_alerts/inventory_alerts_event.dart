import 'package:equatable/equatable.dart';

abstract class InventoryAlertsEvent extends Equatable {
  const InventoryAlertsEvent();

  @override
  List<Object?> get props => [];
}

/// [date] is `YYYY-MM-DD`; omitted means tomorrow (the backend default).
class InventoryAlertsLoaded extends InventoryAlertsEvent {
  const InventoryAlertsLoaded({this.date});

  final String? date;

  @override
  List<Object?> get props => [date];
}

/// 0 = Low stock, 1 = Tomorrow's needs.
class InventoryAlertsTabChanged extends InventoryAlertsEvent {
  const InventoryAlertsTabChanged(this.tabIndex);

  final int tabIndex;

  @override
  List<Object?> get props => [tabIndex];
}
