import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/validators.dart';
import '../../data/models/offer_models.dart';
import '../../data/repositories/store_repository.dart';
import 'add_offer_event.dart';
import 'add_offer_state.dart';

/// Reuses [StoreRepository.getMyStoreProducts] (the expert's own
/// store inventory built in the Basic module) as the selectable list
/// for a new product offer, per the agreed reuse of existing data.
class AddOfferBloc extends Bloc<AddOfferEvent, AddOfferState> {
  AddOfferBloc({StoreRepository? repository})
      : _repository = repository ?? const StoreRepository(),
        super(const AddOfferState()) {
    on<AddOfferStarted>(_onStarted);
    on<AddOfferProductSelected>(_onProductSelected);
    on<AddOfferTypeChanged>(_onTypeChanged);
    on<AddOfferDescriptionChanged>(_onDescriptionChanged);
    on<AddOfferStartDateChanged>(_onStartDateChanged);
    on<AddOfferEndDateChanged>(_onEndDateChanged);
    on<AddOfferSubmitted>(_onSubmitted);
  }

  final StoreRepository _repository;

  void _onStarted(AddOfferStarted event, Emitter<AddOfferState> emit) {
    emit(state.copyWith(availableProducts: _repository.getMyStoreProducts()));
  }

  void _onProductSelected(
    AddOfferProductSelected event,
    Emitter<AddOfferState> emit,
  ) {
    emit(state.copyWith(selectedProductId: event.productId));
  }

  void _onTypeChanged(AddOfferTypeChanged event, Emitter<AddOfferState> emit) {
    final type = OfferType.values.firstWhere(
      (t) => t.name == event.type,
      orElse: () => OfferType.discountOnPrice,
    );
    emit(state.copyWith(type: type));
  }

  void _onDescriptionChanged(
    AddOfferDescriptionChanged event,
    Emitter<AddOfferState> emit,
  ) {
    emit(state.copyWith(description: event.value));
  }

  void _onStartDateChanged(
    AddOfferStartDateChanged event,
    Emitter<AddOfferState> emit,
  ) {
    emit(state.copyWith(startDate: event.value));
  }

  void _onEndDateChanged(
    AddOfferEndDateChanged event,
    Emitter<AddOfferState> emit,
  ) {
    emit(state.copyWith(endDate: event.value));
  }

  Future<void> _onSubmitted(
    AddOfferSubmitted event,
    Emitter<AddOfferState> emit,
  ) async {
    final productError =
        state.selectedProductId == null ? 'Please select a product' : null;
    final dateError = Validators.required(state.startDate) ??
        Validators.required(state.endDate);

    final error = productError ?? dateError;
    if (error != null) {
      emit(state.copyWith(status: AddOfferStatus.failure, errorMessage: error));
      return;
    }

    emit(state.copyWith(status: AddOfferStatus.loading));

    // TODO: Replace with real "create offer" API call.
    await Future<void>.delayed(const Duration(milliseconds: 500));

    emit(state.copyWith(status: AddOfferStatus.success));
  }
}
