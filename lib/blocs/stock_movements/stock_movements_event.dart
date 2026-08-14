import 'package:equatable/equatable.dart';

abstract class StockMovementsEvent extends Equatable {
  const StockMovementsEvent();

  @override
  List<Object?> get props => [];
}

class StockMovementsLoaded extends StockMovementsEvent {
  const StockMovementsLoaded(this.itemId);

  final String itemId;

  @override
  List<Object?> get props => [itemId];
}

/// [movementType] is `in` | `out` | `adjustment`.
///
/// For `adjustment` the backend treats [quantity] as the new balance
/// rather than a delta.
class StockMovementSubmitted extends StockMovementsEvent {
  const StockMovementSubmitted({
    required this.movementType,
    required this.reason,
    required this.quantity,
    this.notes,
  });

  final String movementType;
  final String reason;
  final double quantity;
  final String? notes;

  @override
  List<Object?> get props => [movementType, reason, quantity, notes];
}
