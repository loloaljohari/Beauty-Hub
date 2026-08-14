import 'package:equatable/equatable.dart';
import '../../data/models/salon_model.dart';

enum SalonsStatus { initial, loading, loaded, failure }

class SalonsState extends Equatable {
  const SalonsState({
    this.allSalons = const [],
    this.cities = const [],
    this.selectedCity,
    this.tabIndex = 0,
    this.status = SalonsStatus.initial,
    this.errorMessage,
  });

  final List<SalonModel> allSalons;
  final List<String> cities;
  final String? selectedCity;

  /// 0 = Salons, 1 = Centers.
  final int tabIndex;
  final SalonsStatus status;
  final String? errorMessage;

  bool get isEmpty =>
      status == SalonsStatus.loaded && filteredSalons.isEmpty;

  List<SalonModel> get filteredSalons {
    final typeFilter =
        tabIndex == 0 ? SalonType.salon : SalonType.center;
    return allSalons.where((s) {
      final matchesType = s.type == typeFilter;
      final matchesCity =
          selectedCity == null || s.city == selectedCity;
      return matchesType && matchesCity;
    }).toList();
  }

  SalonsState copyWith({
    List<SalonModel>? allSalons,
    List<String>? cities,
    String? selectedCity,
    int? tabIndex,
    SalonsStatus? status,
    String? errorMessage,
  }) {
    return SalonsState(
      allSalons: allSalons ?? this.allSalons,
      cities: cities ?? this.cities,
      selectedCity: selectedCity ?? this.selectedCity,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [allSalons, cities, selectedCity, tabIndex, status, errorMessage];
}
