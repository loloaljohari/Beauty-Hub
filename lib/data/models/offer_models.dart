import 'package:equatable/equatable.dart';

/// A service-price discount shown on the "Service Discounts" tab,
/// and created via "Add discount".
class DiscountModel extends Equatable {
  const DiscountModel({
    required this.id,
    required this.serviceName,
    required this.basicPrice,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.imageUrl,
  });

  final String id;
  final String serviceName;
  final double basicPrice;
  final double discountPercentage;
  final String startDate;
  final String endDate;
  final bool isActive;
  final String? imageUrl;

  double get newPrice => basicPrice * (1 - discountPercentage / 100);
  String get formattedBasicPrice => '\$${basicPrice.toStringAsFixed(0)}';
  String get formattedNewPrice => '\$${newPrice.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        serviceName,
        basicPrice,
        discountPercentage,
        startDate,
        endDate,
        isActive,
        imageUrl,
      ];
}

/// Type of product offer shown/created on "Products Offers".
enum OfferType { discountOnPrice, buyXGetY, privatePrice }

/// A product offer shown on the "Products Offers" tab, and created
/// via "Add offer" (referencing one or more existing products from
/// the expert's own store).
class OfferModel extends Equatable {
  const OfferModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.startDate,
    required this.endDate,
    this.type = OfferType.discountOnPrice,
    this.isActive = true,
    this.imageUrl,
  });

  final String id;
  final String productName;

  /// Human-readable summary, e.g. "buy tow and get one free".
  final String description;
  final String startDate;
  final String endDate;
  final OfferType type;
  final bool isActive;
  final String? imageUrl;

  @override
  List<Object?> get props => [
        id,
        productName,
        description,
        startDate,
        endDate,
        type,
        isActive,
        imageUrl,
      ];
}

/// A bundled package of products/services shown on the "Packages"
/// tab, and created via "Add Package".
class PackageModel extends Equatable {
  const PackageModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.totalPrice,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    this.includedItemNames = const [],
    this.isActive = true,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String bio;
  final double totalPrice;
  final double discountPercentage;
  final String startDate;
  final String endDate;

  /// Names of the products/services bundled into this package.
  final List<String> includedItemNames;
  final bool isActive;
  final String? imageUrl;

  double get newPrice => totalPrice * (1 - discountPercentage / 100);
  String get formattedTotalPrice => '\$${totalPrice.toStringAsFixed(0)}';
  String get formattedNewPrice => '\$${newPrice.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        name,
        bio,
        totalPrice,
        discountPercentage,
        startDate,
        endDate,
        includedItemNames,
        isActive,
        imageUrl,
      ];
}

/// A single row in the "Rewards" / loyalty-points leaderboard tab.
class RewardCustomerModel extends Equatable {
  const RewardCustomerModel({
    required this.id,
    required this.rank,
    required this.customerName,
    required this.points,
  });

  final String id;
  final int rank;
  final String customerName;
  final int points;

  @override
  List<Object?> get props => [id, rank, customerName, points];
}
