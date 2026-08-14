import 'package:equatable/equatable.dart';
import '../../data/models/material_item_model.dart';
import '../../data/repositories/add_service_repository.dart';

enum ServiceMaterialsStatus { initial, loading, loaded, failure }

enum ServiceMaterialsActionStatus { idle, loading, success, failure }

class ServiceMaterialsState extends Equatable {
  const ServiceMaterialsState({
    this.serviceId = '',
    this.serviceName = '',
    this.materials = const [],
    this.inventory = const [],
    this.status = ServiceMaterialsStatus.initial,
    this.actionStatus = ServiceMaterialsActionStatus.idle,
    this.errorMessage,
  });

  final String serviceId;
  final String serviceName;

  /// Materials already linked to this service.
  final List<ServiceMaterial> materials;

  /// The expert's full inventory, so the picker can offer items that
  /// are not linked yet.
  final List<MaterialItemModel> inventory;

  final ServiceMaterialsStatus status;
  final ServiceMaterialsActionStatus actionStatus;
  final String? errorMessage;

  bool get isEmpty =>
      status == ServiceMaterialsStatus.loaded && materials.isEmpty;

  /// Inventory items not yet attached to this service.
  List<MaterialItemModel> get availableToAdd {
    final linked = materials.map((m) => m.productId).toSet();
    return inventory.where((item) => !linked.contains(item.id)).toList();
  }

  ServiceMaterialsState copyWith({
    String? serviceId,
    String? serviceName,
    List<ServiceMaterial>? materials,
    List<MaterialItemModel>? inventory,
    ServiceMaterialsStatus? status,
    ServiceMaterialsActionStatus? actionStatus,
    String? errorMessage,
  }) {
    return ServiceMaterialsState(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      materials: materials ?? this.materials,
      inventory: inventory ?? this.inventory,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        serviceId,
        serviceName,
        materials,
        inventory,
        status,
        actionStatus,
        errorMessage,
      ];
}
