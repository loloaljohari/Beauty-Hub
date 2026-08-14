import 'package:equatable/equatable.dart';

abstract class ServiceMaterialsEvent extends Equatable {
  const ServiceMaterialsEvent();

  @override
  List<Object?> get props => [];
}

class ServiceMaterialsLoaded extends ServiceMaterialsEvent {
  const ServiceMaterialsLoaded(this.serviceId);

  final String serviceId;

  @override
  List<Object?> get props => [serviceId];
}

/// Links an inventory item to the service, or updates how much of it
/// one session consumes.
class ServiceMaterialUpserted extends ServiceMaterialsEvent {
  const ServiceMaterialUpserted({
    required this.productId,
    required this.quantityPerSession,
    this.unit,
  });

  final String productId;
  final double quantityPerSession;
  final String? unit;

  @override
  List<Object?> get props => [productId, quantityPerSession, unit];
}

class ServiceMaterialRemoved extends ServiceMaterialsEvent {
  const ServiceMaterialRemoved(this.productId);

  final String productId;

  @override
  List<Object?> get props => [productId];
}
