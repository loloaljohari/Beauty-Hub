import 'package:equatable/equatable.dart';
import '../../data/models/offer_models.dart';
import '../../data/models/product_model.dart';

enum AddOfferStatus { initial, loading, success, failure }

class AddOfferState extends Equatable {
  const AddOfferState({
    this.availableProducts = const [],
    this.selectedProductId,
    this.type = OfferType.discountOnPrice,
    this.description = '',
    this.startDate = '',
    this.endDate = '',
    this.status = AddOfferStatus.initial,
    this.errorMessage,
  });

  final List<ProductModel> availableProducts;
  final String? selectedProductId;
  final OfferType type;
  final String description;
  final String startDate;
  final String endDate;
  final AddOfferStatus status;
  final String? errorMessage;

  ProductModel? get selectedProduct {
    if (selectedProductId == null) return null;
    for (final p in availableProducts) {
      if (p.id == selectedProductId) return p;
    }
    return null;
  }

  AddOfferState copyWith({
    List<ProductModel>? availableProducts,
    String? selectedProductId,
    OfferType? type,
    String? description,
    String? startDate,
    String? endDate,
    AddOfferStatus? status,
    String? errorMessage,
  }) {
    return AddOfferState(
      availableProducts: availableProducts ?? this.availableProducts,
      selectedProductId: selectedProductId ?? this.selectedProductId,
      type: type ?? this.type,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        availableProducts,
        selectedProductId,
        type,
        description,
        startDate,
        endDate,
        status,
        errorMessage,
      ];
}
