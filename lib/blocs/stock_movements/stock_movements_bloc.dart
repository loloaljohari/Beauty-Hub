import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'stock_movements_event.dart';
import 'stock_movements_state.dart';

class StockMovementsBloc
    extends Bloc<StockMovementsEvent, StockMovementsState> {
  StockMovementsBloc({MaterialInventoryRepository? repository})
      : _repository = repository ?? const MaterialInventoryRepository(),
        super(const StockMovementsState()) {
    on<StockMovementsLoaded>(_onLoaded);
    on<StockMovementSubmitted>(_onSubmitted);
  }

  final MaterialInventoryRepository _repository;

  Future<void> _onLoaded(
    StockMovementsLoaded event,
    Emitter<StockMovementsState> emit,
  ) async {
    emit(state.copyWith(
      itemId: event.itemId,
      status: StockMovementsStatus.loading,
      errorMessage: null,
    ));

    try {
      final movements = await _repository.getMovements(event.itemId);

      // The item detail is secondary - if it fails the ledger is still
      // worth showing, so it is fetched separately and tolerated.
      var item = state.item;
      try {
        item = await _repository.getMaterial(event.itemId);
      } catch (_) {}

      emit(state.copyWith(
        movements: movements,
        item: item,
        status: StockMovementsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: StockMovementsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: StockMovementsStatus.failure,
        errorMessage: 'Could not load the stock history.',
      ));
    }
  }

  Future<void> _onSubmitted(
    StockMovementSubmitted event,
    Emitter<StockMovementsState> emit,
  ) async {
    emit(state.copyWith(actionStatus: StockMovementActionStatus.loading));

    try {
      await _repository.addMovement(
        itemId: state.itemId,
        movementType: event.movementType,
        reason: event.reason,
        quantity: event.quantity,
        notes: event.notes,
      );

      emit(state.copyWith(actionStatus: StockMovementActionStatus.success));

      // The movement changes the item's balance, so both are refetched.
      add(StockMovementsLoaded(state.itemId));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: StockMovementActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: StockMovementActionStatus.failure,
        errorMessage: 'Could not record this movement.',
      ));
    }
  }
}
