import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/profile_repository.dart';
import 'add_discount_event.dart';
import 'add_discount_state.dart';

/// Reuses [ProfileRepository.getServices] (the same services managed
/// on the Profile "Services" tab) as the selectable list for a new
/// discount, per the agreed reuse of existing data.
class AddDiscountBloc extends Bloc<AddDiscountEvent, AddDiscountState> {
  AddDiscountBloc({
    ProfileRepository? repository,
    OffersRepository? offersRepository,
  })  : _repository = repository ?? const ProfileRepository(),
        _offers = offersRepository ?? const OffersRepository(),
        super(const AddDiscountState()) {
    on<AddDiscountStarted>(_onStarted);
    on<AddDiscountServiceSelected>(_onServiceSelected);
    on<AddDiscountPercentageChanged>(_onPercentageChanged);
    on<AddDiscountStartDateChanged>(_onStartDateChanged);
    on<AddDiscountEndDateChanged>(_onEndDateChanged);
    on<AddDiscountSubmitted>(_onSubmitted);
  }

  final ProfileRepository _repository;
  final OffersRepository _offers;

  Future<void> _onStarted(
    AddDiscountStarted event,
    Emitter<AddDiscountState> emit,
  ) async {
    try {
      emit(state.copyWith(availableServices: await _repository.getServices()));
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: 'Could not load your services.',
      ));
    }
  }

  void _onServiceSelected(
    AddDiscountServiceSelected event,
    Emitter<AddDiscountState> emit,
  ) {
    emit(state.copyWith(selectedServiceId: event.serviceId));
  }

  void _onPercentageChanged(
    AddDiscountPercentageChanged event,
    Emitter<AddDiscountState> emit,
  ) {
    emit(state.copyWith(percentage: event.value));
  }

  void _onStartDateChanged(
    AddDiscountStartDateChanged event,
    Emitter<AddDiscountState> emit,
  ) {
    emit(state.copyWith(startDate: event.value));
  }

  void _onEndDateChanged(
    AddDiscountEndDateChanged event,
    Emitter<AddDiscountState> emit,
  ) {
    emit(state.copyWith(endDate: event.value));
  }

  Future<void> _onSubmitted(
    AddDiscountSubmitted event,
    Emitter<AddDiscountState> emit,
  ) async {
    final serviceError =
        state.selectedServiceId == null ? 'Please select a service' : null;
    final percentageError = Validators.required(state.percentage);
    final dateError = Validators.required(state.startDate) ??
        Validators.required(state.endDate);

    final error = serviceError ?? percentageError ?? dateError;
    if (error != null) {
      emit(
        state.copyWith(status: AddDiscountStatus.failure, errorMessage: error),
      );
      return;
    }

    // The backend requires end_at to be strictly after start_at
    // (`after:start_at`). Catching it here beats a 422 after submit.
    final start = DateTime.tryParse(state.startDate);
    final end = DateTime.tryParse(state.endDate);

    if (start == null || end == null) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: 'Please pick both dates.',
      ));
      return;
    }

    if (!end.isAfter(start)) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: 'The end date must come after the start date.',
      ));
      return;
    }

    final percent = double.tryParse(state.percentage);
    if (percent == null || percent < 1 || percent > 99) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: 'Enter a discount between 1 and 99 percent.',
      ));
      return;
    }

    emit(state.copyWith(status: AddDiscountStatus.loading));

    try {
      // POST /expert/offers. The server computes the discounted price
      // itself from the service's current price, so only the percentage
      // is sent.
      await _offers.createDiscount(
        serviceId: int.parse(state.selectedServiceId!),
        title: state.selectedService?.name ?? 'Discount',
        discountPercent: percent,
        startAt: state.startDate,
        endAt: state.endDate,
      );

      emit(state.copyWith(status: AddDiscountStatus.success));
    } on ApiException catch (e) {
      // A common one here is OFFER_ALREADY_ACTIVE - the backend refuses
      // a second live offer on the same service, and its message says
      // to end the existing one first.
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: AddDiscountStatus.failure,
        errorMessage: 'Could not create the discount. Please try again.',
      ));
    }
  }
}
