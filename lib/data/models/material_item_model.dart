import 'package:beautyhup/core/config/app_config.dart';
import 'package:beautyhup/core/network/api_response.dart';
import 'package:equatable/equatable.dart';

enum MaterialStatus { normal, expiringSoon, outOfStock }

/// A single material/stock item shown on "Material Inventory"
/// (the expert's own salon supplies, distinct from [ProductModel]
/// which represents store-sold products).
class MaterialItemModel extends Equatable {
  const MaterialItemModel({
    this.min_stock = 5,
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    this.imageUrl,
    this.category = '',
    this.categoryId = '',
    this.description = '',
    this.price = 0,
    this.peopleNeedingCount = 0,
    this.sku = '',
    this.wholesalePrice = 0,
  });

  final String id;
  final String name;
  final int quantity;
  final String expiryDate;
  final String? imageUrl;

  /// Display name of the category (e.g. "Hair Care Products").
  final String category;

  /// The category's numeric id. Kept separate from [category] because
  /// the API sends both, the dropdown needs the id, and the label needs
  /// the name - conflating them is what broke the category dropdown.
  final String categoryId;
  final String description;
  final double price;
  final String sku;
  final double wholesalePrice;

  final double min_stock;

  /// "Number of people need it" field from the Add Material form.
  final int peopleNeedingCount;

  MaterialStatus get status {
    if (quantity == 0) return MaterialStatus.outOfStock;
    // Static demo heuristic: treat any item with an expiry date as
    // "expiring soon" when quantity is low. Replace with real date
    // comparison once dynamic dates are available.
    if (quantity <= min_stock) return MaterialStatus.expiringSoon;
    return MaterialStatus.normal;
  }
  /// Maps `InventoryItemResource`.
  ///
  /// Three things the previous version got wrong:
  ///  * `stock_quantity` is cast to `(float)` server-side, so
  ///    `json['stock_quantity'] ?? 0` assigned a double to an int field.
  ///  * the image URL was built by string-replacing `/api/expert` out
  ///    of the base URL, which broke on any other host or prefix.
  ///  * `price` was read from `wholesale_price`, so both fields showed
  ///    the wholesale figure.
  factory MaterialItemModel.fromJson(Map<String, dynamic> json) {
    final category = ApiResponse.asMap(json['category']);

    return MaterialItemModel(
      id: ApiResponse.asString(json['id']),
      name: ApiResponse.asString(json['name']),
      quantity: ApiResponse.asDouble(json['stock_quantity']).round(),
      // The API has no expiry column; `created_at` is what it exposes.
      expiryDate: ApiResponse.asDate(json['created_at']),
      imageUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(json['main_image']),
      ),
      category: ApiResponse.asString(
        category['name_en'],
        fallback: ApiResponse.asString(category['name_ar']),
      ),
      categoryId: ApiResponse.asString(category['id']),
      description: ApiResponse.asString(json['description']),
      sku: ApiResponse.asString(json['sku']),
      price: ApiResponse.asDouble(json['price']),
      wholesalePrice: ApiResponse.asDouble(json['wholesale_price']),
      min_stock: ApiResponse.asDouble(json['min_stock_threshold'], fallback: 5),
      peopleNeedingCount:
          ApiResponse.asInt(json['sufficient_for_persons']),
    );
  }


  MaterialItemModel copyWith({int? quantity}) {
    return MaterialItemModel(
      min_stock: min_stock,
      id: id,
      name: name,
      quantity: quantity ?? this.quantity,
      expiryDate: expiryDate,
      imageUrl: imageUrl,
      category: category,
      categoryId: categoryId,
      description: description,
      price: price,
      sku: sku,
      wholesalePrice: wholesalePrice,
      peopleNeedingCount: peopleNeedingCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        expiryDate,
        imageUrl,
        category,
        categoryId,
        description,
        price,
        sku,
        wholesalePrice,
        peopleNeedingCount,
      ];
}
