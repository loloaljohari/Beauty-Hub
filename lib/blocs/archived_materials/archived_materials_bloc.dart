import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'archived_materials_event.dart';
import 'archived_materials_state.dart';class ArchivedMaterialsBloc
    extends Bloc<ArchivedMaterialsEvent, ArchivedMaterialsState> {
  ArchivedMaterialsBloc({MaterialInventoryRepository? repository})
      : _repository = repository ?? const MaterialInventoryRepository(),
        super(const ArchivedMaterialsState()) {
    on<ArchivedMaterialsLoaded>(_onLoaded);
    on<ArchivedMaterialRestored>(_onRestored);
  }

  final MaterialInventoryRepository _repository;

  Future<void> _onLoaded(
    ArchivedMaterialsLoaded event,
    Emitter<ArchivedMaterialsState> emit,
  ) async {
    emit(state.copyWith(status: ArchivedMaterialsStatus.loading));
    try {
      final materials = await _repository.getArchivedMaterials();
      emit(state.copyWith(
        materials: materials,
        status: ArchivedMaterialsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ArchivedMaterialsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArchivedMaterialsStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRestored(
    ArchivedMaterialRestored event,
    Emitter<ArchivedMaterialsState> emit,
  ) async {
    emit(state.copyWith(restoringId: event.id));
    try {
      await _repository.restoreMaterial(event.id);
      final updated =
          state.materials.where((m) => m.id != event.id).toList();
      emit(state.copyWith(
        materials: updated,
        restoringId: null,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        restoringId: null,
        errorMessage: e.message,
      ));
    } catch (e) {
      emit(state.copyWith(
        restoringId: null,
        errorMessage: e.toString(),
      ));
    }
  }
}