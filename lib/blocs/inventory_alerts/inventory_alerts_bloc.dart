import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/material_inventory_repository.dart';
import 'inventory_alerts_event.dart';
import 'inventory_alerts_state.dart';

class InventoryAlertsBloc
    extends Bloc<InventoryAlertsEvent, InventoryAlertsState> {
  InventoryAlertsBloc({MaterialInventoryRepository? repository})
      : _repository = repository ?? const MaterialInventoryRepository(),
        super(const InventoryAlertsState()) {
    on<InventoryAlertsLoaded>(_onLoaded);
    on<InventoryAlertsTabChanged>(_onTabChanged);
  }

  final MaterialInventoryRepository _repository;

  Future<void> _onLoaded(
    InventoryAlertsLoaded event,
    Emitter<InventoryAlertsState> emit,
  ) async {
    emit(state.copyWith(
      status: InventoryAlertsStatus.loading,
      errorMessage: null,
    ));

    try {
      final alerts = await _repository.getInventoryAlerts();

      // The smart alert depends on service_materials being linked up.
      // If nothing is linked it returns an empty list rather than
      // failing, but a genuine error here should not hide the low-stock
      // tab, which is useful on its own.
      SmartAlert? smart;
      try {
        smart = await _repository.getSmartAlert(date: event.date);
      } catch (_) {}

      emit(state.copyWith(
        lowStock: (alerts['items'] as List).cast<MaterialItemModel>(),
        smartAlert: smart,
        status: InventoryAlertsStatus.loaded,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: InventoryAlertsStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: InventoryAlertsStatus.failure,
        errorMessage: 'Could not load your stock alerts.',
      ));
    }
  }

  void _onTabChanged(
    InventoryAlertsTabChanged event,
    Emitter<InventoryAlertsState> emit,
  ) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }
}
