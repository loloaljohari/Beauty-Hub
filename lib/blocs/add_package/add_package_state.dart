import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/models/service_model.dart';

enum AddPackageStatus { initial, loading, success, failure }

class AddPackageState extends Equatable {
  const AddPackageState({
    this.availableProducts = const [],
    this.availableServices = const [],
    this.selectedItemIds = const [],
    this.name = '',
    this.bio = '',
    this.price = '',
    this.discountPercentage = '',
    this.startDate = '',
    this.endDate = '',
    this.status = AddPackageStatus.initial,
    this.errorMessage,
    this.packageId,
  });

  final List<ProductModel> availableProducts;
  final List<ServiceModel> availableServices;

  /// Combined set of selected product/service ids.
  final List<String> selectedItemIds;

  final String name;
  final String bio;
  final String price;
  final String discountPercentage;
  final String startDate;
  final String endDate;
  final AddPackageStatus status;
  final String? errorMessage;

  /// Set when editing an existing bundle.
  final String? packageId;

  bool get isEditing => packageId != null;

  /// Pre-discount total of the ticked items, for the live preview.
  /// The authoritative figure still comes from the server, which uses
  /// frozen line prices rather than today's.
  double get selectedTotal {
    var total = 0.0;

    for (final key in selectedItemIds) {
      final parts = key.split(':');
      if (parts.length < 2) continue;

      if (parts.first == 'service') {
        for (final service in availableServices) {
          if (service.id == parts[1]) total += service.price;
        }
      } else {
        for (final product in availableProducts) {
          if (product.id == parts[1]) total += product.price;
        }
      }
    }

    return total;
  }

  AddPackageState copyWith({
    List<ProductModel>? availableProducts,
    List<ServiceModel>? availableServices,
    List<String>? selectedItemIds,
    String? name,
    String? bio,
    String? price,
    String? discountPercentage,
    String? startDate,
    String? endDate,
    AddPackageStatus? status,
    String? errorMessage,
    String? packageId,
  }) {
    return AddPackageState(
      availableProducts: availableProducts ?? this.availableProducts,
      availableServices: availableServices ?? this.availableServices,
      selectedItemIds: selectedItemIds ?? this.selectedItemIds,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      price: price ?? this.price,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      errorMessage: errorMessage,
      packageId: packageId ?? this.packageId,
    );
  }

  @override
  List<Object?> get props => [
        availableProducts,
        availableServices,
        selectedItemIds,
        name,
        bio,
        price,
        discountPercentage,
        startDate,
        endDate,
        status,
        errorMessage,
        packageId,
      ];
}
