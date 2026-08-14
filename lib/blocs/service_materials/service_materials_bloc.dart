import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/repositories/add_service_repository.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'service_materials_event.dart';
import 'service_materials_state.dart';

class ServiceMaterialsBloc
    extends Bloc<ServiceMaterialsEvent, ServiceMaterialsState> {
  ServiceMaterialsBloc({
    AddServiceRepository? serviceRepository,
    MaterialInventoryRepository? inventoryRepository,
  })  : _services = serviceRepository ?? const AddServiceRepository(),
        _inventory = inventoryRepository ?? const MaterialInventoryRepository(),
        super(const ServiceMaterialsState()) {
    on<ServiceMaterialsLoaded>(_onLoaded);
    on<ServiceMaterialUpserted>(_onUpserted);
    on<ServiceMaterialRemoved>(_onRemoved);
  }

  final AddServiceRepository _services;
  final MaterialInventoryRepository _inventory;

  Future<void> _onLoaded(
    ServiceMaterialsLoaded event,
    Emitter<ServiceMaterialsState> emit,
  ) async {
    emit(state.copyWith(
      serviceId: event.serviceId,
      status: ServiceMaterialsStatus.loading,
      errorMessage: null,
    ));

    try {
      final linked = await _services.getServiceMaterials(event.serviceId);

      // Needed for the "add material" picker. A failure here still
      // leaves the linked list usable, so it is tolerated.
      var inventory = state.inventory;
      try {
        inventory = await _inventory.getMaterials();
      } catch (_) {}

      emit(state.copyWith(
        serviceName: linked.serviceName,
        materials: linked.materials,
        inventory: inventory,
        status: ServiceMaterialsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: ServiceMaterialsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: ServiceMaterialsStatus.failure,
        errorMessage: 'Could not load the materials for this service.',
      ));
    }
  }

  /// The endpoint replaces the whole set, so adding or editing one row
  /// means sending the full list back with that row merged in.
  Future<void> _onUpserted(
    ServiceMaterialUpserted event,
    Emitter<ServiceMaterialsState> emit,
  ) async {
    final next = <String, ServiceMaterialInput>{
      for (final material in state.materials)
        material.productId: ServiceMaterialInput(
          productId: material.productId,
          quantityPerSession: material.quantityPerSession,
          unit: material.unit,
        ),
      event.productId: ServiceMaterialInput(
        productId: event.productId,
        quantityPerSession: event.quantityPerSession,
        unit: event.unit,
      ),
    };

    await _sync(emit, next.values.toList());
  }

  Future<void> _onRemoved(
    ServiceMaterialRemoved event,
    Emitter<ServiceMaterialsState> emit,
  ) async {
    final next = state.materials
        .where((material) => material.productId != event.productId)
        .map((material) => ServiceMaterialInput(
              productId: material.productId,
              quantityPerSession: material.quantityPerSession,
              unit: material.unit,
            ))
        .toList();

    await _sync(emit, next);
  }

  Future<void> _sync(
    Emitter<ServiceMaterialsState> emit,
    List<ServiceMaterialInput> materials,
  ) async {
    emit(state.copyWith(actionStatus: ServiceMaterialsActionStatus.loading));

    try {
      final updated = await _services.syncServiceMaterials(
        serviceId: state.serviceId,
        materials: materials,
      );

      emit(state.copyWith(
        materials: updated.materials,
        serviceName: updated.serviceName,
        actionStatus: ServiceMaterialsActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: ServiceMaterialsActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: ServiceMaterialsActionStatus.failure,
        errorMessage: 'Could not save the materials.',
      ));
    }
  }
}
