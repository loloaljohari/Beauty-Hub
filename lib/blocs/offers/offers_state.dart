import 'package:equatable/equatable.dart';
import '../../data/models/offer_models.dart';
import '../../data/repositories/offers_repository.dart';

enum OffersStatus { initial, loading, loaded, failure }

enum OffersActionStatus { initial, loading, success, failure }

class OffersState extends Equatable {
  const OffersState({
    this.discounts = const [],
    this.productOffers = const [],
    this.packages = const [],
    this.topCustomers = const [],
    this.tabIndex = 0,
    this.status = OffersStatus.initial,
    this.actionStatus = OffersActionStatus.initial,
    this.birthdayFollowers = const [],
    this.errorMessage,
  });

  final List<DiscountModel> discounts;
  final List<OfferModel> productOffers;
  final List<PackageModel> packages;
  final List<RewardCustomerModel> topCustomers;

  /// 0 = Service Discounts, 1 = Products Offers, 2 = Packages,
  /// 3 = Rewards.
  final int tabIndex;
  final OffersStatus status;
  final OffersActionStatus actionStatus;

  /// Rewards tab: followers with a birthday today, from
  /// `GET /expert/loyalty/birthdays`.
  final List<BirthdayFollower> birthdayFollowers;
  final String? errorMessage;

  bool get isEmpty => status == OffersStatus.loaded && discounts.isEmpty;

  OffersState copyWith({
    List<DiscountModel>? discounts,
    List<OfferModel>? productOffers,
    List<PackageModel>? packages,
    List<RewardCustomerModel>? topCustomers,
    int? tabIndex,
    OffersStatus? status,
    OffersActionStatus? actionStatus,
    List<BirthdayFollower>? birthdayFollowers,
    String? errorMessage,
  }) {
    return OffersState(
      discounts: discounts ?? this.discounts,
      productOffers: productOffers ?? this.productOffers,
      packages: packages ?? this.packages,
      topCustomers: topCustomers ?? this.topCustomers,
      tabIndex: tabIndex ?? this.tabIndex,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      birthdayFollowers: birthdayFollowers ?? this.birthdayFollowers,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        discounts,
        productOffers,
        packages,
        topCustomers,
        tabIndex,
        status,
        actionStatus,
        birthdayFollowers,
        errorMessage,
      ];
}
