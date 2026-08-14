import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/packages_repository.dart';
import 'add_package_event.dart';
import 'add_package_state.dart';

/// Builds a bundle of the expert's own services and products.
///
/// The selectable list comes from
/// `GET /expert/packages/available-items`, which already excludes raw
/// materials - `products` holds both those and shop items, and only
/// `is_for_sale` tells them apart.
///
/// Selection is keyed by `"service:3"` / `"product:3"` rather than a
/// bare id, because a service and a product can share the same number
/// and a bare id would tick the wrong row.
class AddPackageBloc extends Bloc<AddPackageEvent, AddPackageState> {
  AddPackageBloc({PackagesRepository? repository})
      : _repository = repository ?? const PackagesRepository(),
        super(const AddPackageState()) {
    on<AddPackageStarted>(_onStarted);
    on<AddPackageNameChanged>(_onNameChanged);
    on<AddPackageBioChanged>(_onBioChanged);
    on<AddPackageItemToggled>(_onItemToggled);
    on<AddPackagePriceChanged>(_onPriceChanged);
    on<AddPackageDiscountChanged>(_onDiscountChanged);
    on<AddPackageStartDateChanged>(_onStartDateChanged);
    on<AddPackageEndDateChanged>(_onEndDateChanged);
    on<AddPackageSubmitted>(_onSubmitted);
  }

  final PackagesRepository _repository;

  Future<void> _onStarted(
    AddPackageStarted event,
    Emitter<AddPackageState> emit,
  ) async {
    emit(state.copyWith(status: AddPackageStatus.initial, errorMessage: null));

    try {
      final items = await _repository.getAvailableItems();

      emit(
        state.copyWith(
          availableProducts: items.products,
          availableServices: items.services,
        ),
      );

      if (event.packageId != null) {
        await _loadExisting(event.packageId!, emit);
      }
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddPackageStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddPackageStatus.failure,
        errorMessage: 'Could not load your services and products.',
      ));
    }
  }

  /// Fills the form when editing. The stored line prices are snapshots,
  /// so the totals shown come from the server, not from re-pricing the
  /// current services.
  Future<void> _loadExisting(
    String packageId,
    Emitter<AddPackageState> emit,
  ) async {
    final detail = await _repository.getPackage(packageId);

    emit(state.copyWith(
      packageId: packageId,
      name: detail.package.name,
      bio: detail.package.bio,
      price: detail.package.totalPrice.toStringAsFixed(0),
      discountPercentage:
          detail.package.discountPercentage.toStringAsFixed(0),
      startDate: detail.package.startDate,
      endDate: detail.package.endDate,
      selectedItemIds: detail.items.map((line) => line.key).toList(),
    ));
  }

  void _onNameChanged(
    AddPackageNameChanged event,
    Emitter<AddPackageState> emit,
  ) {
    emit(state.copyWith(name: event.value));
  }

  void _onBioChanged(AddPackageBioChanged event, Emitter<AddPackageState> emit) {
    emit(state.copyWith(bio: event.value));
  }

  void _onItemToggled(
    AddPackageItemToggled event,
    Emitter<AddPackageState> emit,
  ) {
    final updated = List<String>.from(state.selectedItemIds);
    if (updated.contains(event.itemId)) {
      updated.remove(event.itemId);
    } else {
      updated.add(event.itemId);
    }
    emit(state.copyWith(selectedItemIds: updated));
  }

  void _onPriceChanged(
    AddPackagePriceChanged event,
    Emitter<AddPackageState> emit,
  ) {
    emit(state.copyWith(price: event.value));
  }

  void _onDiscountChanged(
    AddPackageDiscountChanged event,
    Emitter<AddPackageState> emit,
  ) {
    emit(state.copyWith(discountPercentage: event.value));
  }

  void _onStartDateChanged(
    AddPackageStartDateChanged event,
    Emitter<AddPackageState> emit,
  ) {
    emit(state.copyWith(startDate: event.value));
  }

  void _onEndDateChanged(
    AddPackageEndDateChanged event,
    Emitter<AddPackageState> emit,
  ) {
    emit(state.copyWith(endDate: event.value));
  }

  Future<void> _onSubmitted(
    AddPackageSubmitted event,
    Emitter<AddPackageState> emit,
  ) async {
    final nameError = Validators.required(state.name);
    final itemsError =
        state.selectedItemIds.isEmpty ? 'Select at least one item' : null;
    final priceError = Validators.required(state.price);

    final error = nameError ?? itemsError ?? priceError;
    if (error != null) {
      emit(
        state.copyWith(status: AddPackageStatus.failure, errorMessage: error),
      );
      return;
    }

    // The server rejects an end date on or before the start
    // (`after:start_at`), so it is caught here for a clearer message.
    if (state.startDate.isNotEmpty && state.endDate.isNotEmpty) {
      final start = DateTime.tryParse(state.startDate);
      final end = DateTime.tryParse(state.endDate);

      if (start != null && end != null && !end.isAfter(start)) {
        emit(state.copyWith(
          status: AddPackageStatus.failure,
          errorMessage: 'The end date must come after the start date.',
        ));
        return;
      }
    }

    emit(state.copyWith(status: AddPackageStatus.loading));

    final items = state.selectedItemIds
        .map(PackageItemInput.fromKey)
        .toList();

    // `price` on this form is the pre-discount total, which the server
    // computes itself from the frozen line prices. Only the percentage
    // is sent - sending a total the server would ignore invites the two
    // to disagree.
    final discount = double.tryParse(state.discountPercentage.trim()) ?? 0;

    try {
      if (state.isEditing) {
        await _repository.updatePackage(
          packageId: state.packageId!,
          name: state.name,
          items: items,
          description: state.bio,
          discountPercent: discount,
          startAt: state.startDate,
          endAt: state.endDate,
        );
      } else {
        await _repository.createPackage(
          name: state.name,
          items: items,
          description: state.bio,
          discountPercent: discount,
          startAt: state.startDate,
          endAt: state.endDate,
        );
      }

      emit(state.copyWith(status: AddPackageStatus.success));
    } on ApiException catch (e) {
      // ITEM_NOT_OWNED and ITEM_NOT_SELLABLE both arrive as readable
      // messages from the server.
      emit(state.copyWith(
        status: AddPackageStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddPackageStatus.failure,
        errorMessage: 'Could not save the package. Please try again.',
      ));
    }
  }
}
