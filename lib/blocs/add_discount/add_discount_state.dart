import 'package:equatable/equatable.dart';
import '../../data/models/service_model.dart';

enum AddDiscountStatus { initial, loading, success, failure }

class AddDiscountState extends Equatable {
  const AddDiscountState({
    this.availableServices = const [],
    this.selectedServiceId,
    this.percentage = '',
    this.startDate = '',
    this.endDate = '',
    this.status = AddDiscountStatus.initial,
    this.errorMessage,
  });

  final List<ServiceModel> availableServices;
  final String? selectedServiceId;
  final String percentage;
  final String startDate;
  final String endDate;
  final AddDiscountStatus status;
  final String? errorMessage;

  ServiceModel? get selectedService {
    if (selectedServiceId == null) return null;
    for (final s in availableServices) {
      if (s.id == selectedServiceId) return s;
    }
    return null;
  }

  AddDiscountState copyWith({
    List<ServiceModel>? availableServices,
    String? selectedServiceId,
    String? percentage,
    String? startDate,
    String? endDate,
    AddDiscountStatus? status,
    String? errorMessage,
  }) {
    return AddDiscountState(
      availableServices: availableServices ?? this.availableServices,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      percentage: percentage ?? this.percentage,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        availableServices,
        selectedServiceId,
        percentage,
        startDate,
        endDate,
        status,
        errorMessage,
      ];
}
