import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import '../../data/repositories/offers_repository.dart';
import '../../data/repositories/packages_repository.dart';
import 'offers_event.dart';
import 'offers_state.dart';

class OffersBloc extends Bloc<OffersEvent, OffersState> {
  OffersBloc({
    OffersRepository? repository,
    PackagesRepository? packagesRepository,
  })  : _repository = repository ?? const OffersRepository(),
        _packages = packagesRepository ?? const PackagesRepository(),
        super(const OffersState()) {
    on<OffersLoaded>(_onLoaded);
    on<OffersTabChanged>(_onTabChanged);
    on<DiscountDeleted>(_onDiscountDeleted);
    on<OfferDeleted>(_onOfferDeleted);
    on<PackageDeleted>(_onPackageDeleted);
    on<BirthdayGiftGranted>(_onBirthdayGiftGranted);
  }

  final OffersRepository _repository;
  final PackagesRepository _packages;

  Future<void> _onLoaded(
    OffersLoaded event,
    Emitter<OffersState> emit,
  ) async {
    emit(state.copyWith(status: OffersStatus.loading, errorMessage: null));

    try {
      // Three of the four tabs are live now. Product offers is still
      // the exception: `offers.service_id` is a foreign key to
      // `services`, so there is no product-offer concept to read.
      final discounts = await _repository.getDiscounts();

      // Packages need their own migration; tolerate a 404 so the
      // discounts tab still works against an older backend.
      var packages = state.packages;
      try {
        packages = await _packages.getPackages();
      } on ApiException catch (e) {
        if (!e.isNotFound) rethrow;
      } catch (_) {}

      List<BirthdayFollower> birthdays = const [];
      try {
        birthdays = await _repository.getBirthdayFollowers();
      } on ApiException {
        // The rewards tab is secondary; a failure there must not blank
        // out the discounts the user came to see.
      }

      emit(
        state.copyWith(
          discounts: discounts,
          packages: packages,
          birthdayFollowers: birthdays,
          tabIndex: await StorageService.getLastOffersTab(),
          status: OffersStatus.loaded,
        ),
      );
    } on ApiException catch (e) {
      emit(state.copyWith(
        status: OffersStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        status: OffersStatus.failure,
        errorMessage: 'Could not load your offers.',
      ));
    }
  }

  void _onTabChanged(OffersTabChanged event, Emitter<OffersState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
    // Small continuity win: reopen on the tab the user last used.
    StorageService.saveLastOffersTab(event.tabIndex);
  }

  /// "Delete" on a discount maps to `POST /expert/offers/{id}/end` -
  /// the backend deactivates offers rather than deleting them.
  Future<void> _onDiscountDeleted(
    DiscountDeleted event,
    Emitter<OffersState> emit,
  ) async {
    final previous = state.discounts;

    emit(state.copyWith(
      discounts: previous.where((d) => d.id != event.id).toList(),
      actionStatus: OffersActionStatus.loading,
    ));

    try {
      await _repository.endOffer(event.id);
      emit(state.copyWith(actionStatus: OffersActionStatus.success));
    } on ApiException catch (e) {
      emit(state.copyWith(
        discounts: previous,
        actionStatus: OffersActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        discounts: previous,
        actionStatus: OffersActionStatus.failure,
        errorMessage: 'Could not end this offer.',
      ));
    }
  }

  // There is still no product-offer endpoint, so this stays local.
  void _onOfferDeleted(OfferDeleted event, Emitter<OffersState> emit) {
    emit(state.copyWith(
      productOffers:
          state.productOffers.where((o) => o.id != event.id).toList(),
    ));
  }

  /// DELETE /expert/packages/{id}. A bundle that has already been
  /// bought is deactivated server-side rather than removed, so the list
  /// is refetched instead of assuming the row disappeared.
  Future<void> _onPackageDeleted(
    PackageDeleted event,
    Emitter<OffersState> emit,
  ) async {
    final previous = state.packages;

    emit(state.copyWith(
      packages: previous.where((p) => p.id != event.id).toList(),
      actionStatus: OffersActionStatus.loading,
    ));

    try {
      await _packages.deletePackage(event.id);

      emit(state.copyWith(
        packages: await _packages.getPackages(),
        actionStatus: OffersActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        packages: previous,
        actionStatus: OffersActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        packages: previous,
        actionStatus: OffersActionStatus.failure,
        errorMessage: 'Could not delete this package.',
      ));
    }
  }

  Future<void> _onBirthdayGiftGranted(
    BirthdayGiftGranted event,
    Emitter<OffersState> emit,
  ) async {
    emit(state.copyWith(actionStatus: OffersActionStatus.loading));

    try {
      await _repository.grantBirthdayGift(event.userId);
      final refreshed = await _repository.getBirthdayFollowers();
      emit(state.copyWith(
        birthdayFollowers: refreshed,
        actionStatus: OffersActionStatus.success,
      ));
    } on ApiException catch (e) {
      emit(state.copyWith(
        actionStatus: OffersActionStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      emit(state.copyWith(
        actionStatus: OffersActionStatus.failure,
        errorMessage: 'Could not send the birthday gift.',
      ));
    }
  }
}
