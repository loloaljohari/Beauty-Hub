import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'material_inventory_event.dart';
import 'material_inventory_state.dart';

class MaterialInventoryBloc
    extends Bloc<MaterialInventoryEvent, MaterialInventoryState> {
  MaterialInventoryBloc({MaterialInventoryRepository? repository})
      : _repository = repository ?? const MaterialInventoryRepository(),
        super(const MaterialInventoryState()) {
    on<MaterialInventoryLoaded>(_onLoaded);
    on<MaterialQuantityChanged>(_onQuantityChanged);
    on<MaterialDeleted>(_onDeleted);
  }

  final MaterialInventoryRepository _repository;

  Future<void> _onLoaded(
    MaterialInventoryLoaded event,
    Emitter<MaterialInventoryState> emit,
  ) async {
    emit(state.copyWith(
      status: MaterialInventoryStatus.loading,
      errorMessage: null,
    ));

    try {
      // This used to make FOUR identical GET /inventory calls per load
      // (one for the list, one per counter). One fetch now feeds all of
      // them.
      final materials = await _repository.getMaterials();
      final counters = _countersFrom(materials);

      emit(
        state.copyWith(
          materials: materials,
          itemsCount: counters.total,
          expiringSoonCount: counters.lowStock,
          outOfStockCount: counters.outOfStock,
          status: MaterialInventoryStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: MaterialInventoryStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: MaterialInventoryStatus.failure,
        errorMessage: 'Could not load your inventory.',
      ));
    }
  }

  InventoryCounters _countersFrom(List<MaterialItemModel> materials) {
    return InventoryCounters(
      total: materials.length,
      lowStock: materials
          .where((m) => m.quantity > 0 && m.quantity <= m.min_stock)
          .length,
      outOfStock: materials.where((m) => m.quantity == 0).length,
    );
  }

  /// Local-only: the +/- stepper adjusts the displayed figure. To
  /// actually change stock the backend wants a movement row
  /// (`POST /expert/inventory/{id}/movements`), which is what
  /// [MaterialStockAdjusted] does.
  void _onQuantityChanged(
    MaterialQuantityChanged event,
    Emitter<MaterialInventoryState> emit,
  ) {
    final updated = state.materials.map((m) {
      if (m.id == event.materialId) {
        final next = (m.quantity + event.delta).clamp(0, 9999);
        return m.copyWith(quantity: next);
      }
      return m;
    }).toList();
    emit(state.copyWith(materials: updated));
  }

  void _onDeleted(
    MaterialDeleted event,
    Emitter<MaterialInventoryState> emit,
  ) async {
    emit(state.copyWith(
      status: MaterialInventoryStatus.loading,
    ));
    try {
      await _repository.deleteMaterial(event.materialId);

      final updated = await _repository.getMaterials();
      final counters = _countersFrom(updated);

      emit(state.copyWith(
        materials: updated,
        itemsCount: counters.total,
        expiringSoonCount: counters.lowStock,
        outOfStockCount: counters.outOfStock,
        status: MaterialInventoryStatus.loaded,
        actionStatus: MaterialActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: MaterialActionStatus.failure,
        // errorMessage: AuthFailure.fromStatusCode(e.statusCode, e.message),
      ));
    } catch (e) {
      print(e.toString());
      emit(state.copyWith(
        actionStatus: MaterialActionStatus.failure,
        // errorMessage: e.toString(),
      ));
    }
    // final updated =
    //     state.materials.where((m) => m.id != event.materialId).toList();
    // emit(state.copyWith(materials: updated));
  }
}
