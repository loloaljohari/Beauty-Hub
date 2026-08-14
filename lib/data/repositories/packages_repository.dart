import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/offer_models.dart';
import '../models/product_model.dart';
import '../models/service_model.dart';

/// Bundles of services and/or products sold together at one price.
///
/// Backed by `packages` + `package_items`, which exist only after the
/// packages migration. Against an older backend every call here 404s.
///
/// Two server behaviours worth knowing before changing anything:
///
///  1. Prices are SNAPSHOTS. The line price is frozen when the package
///     is saved, so editing a service's price later does not silently
///     reprice a published bundle. That is why the totals come back
///     from the server instead of being computed here.
///
///  2. Sending `items` REPLACES the whole line set. There is no partial
///     update of a single line.
class PackagesRepository {
  const PackagesRepository();

  /// GET /expert/packages -> data.packages
  Future<List<PackageModel>> getPackages({bool? activeOnly}) async {
    final response = await ApiClient.get(
      ApiEndpoints.packages,
      query: {if (activeOnly != null) 'active': activeOnly ? 1 : 0},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['packages'])
        .map(_toPackage)
        .toList();
  }

  /// GET /expert/packages/{id} -> data.package
  Future<PackageDetail> getPackage(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.package(id));
    final row = ApiResponse.object(response, 'package');

    return PackageDetail(
      package: _toPackage(row),
      items: ApiResponse.asMapList(row['items'])
          .map((item) => PackageLine(
                itemType: ApiResponse.asString(item['item_type']),
                itemId: ApiResponse.asString(item['item_id']),
                name: ApiResponse.asString(item['name']),
                quantity: ApiResponse.asInt(item['quantity'], fallback: 1),
                unitPrice: ApiResponse.asDouble(item['price_snapshot']),
              ))
          .toList(),
    );
  }

  /// POST /expert/packages (multipart, so a cover image can ride along).
  ///
  /// `items` is sent as a JSON string because the request is multipart;
  /// the controller accepts either that or a real array.
  Future<void> createPackage({
    required String name,
    required List<PackageItemInput> items,
    String? description,
    double? discountPercent,
    String? startAt,
    String? endAt,
    int? maxPurchases,
    String? coverImagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.packages,
      fields: {
        'name': name,
        'items': _encodeItems(items),
        if (description != null && description.isNotEmpty)
          'description': description,
        if (discountPercent != null)
          'discount_percent': discountPercent.toString(),
        if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
        if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
        if (maxPurchases != null) 'max_purchases': maxPurchases.toString(),
      },
      files: {
        if (coverImagePath != null && coverImagePath.isNotEmpty)
          'cover_image': coverImagePath,
      },
    );
  }

  /// POST /expert/packages/{id}
  ///
  /// Omit [items] to leave the lines untouched and change only the
  /// metadata; pass them to replace the set entirely.
  Future<void> updatePackage({
    required Object packageId,
    String? name,
    List<PackageItemInput>? items,
    String? description,
    double? discountPercent,
    String? startAt,
    String? endAt,
    int? maxPurchases,
    String? coverImagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.package(packageId),
      fields: {
        if (name != null && name.isNotEmpty) 'name': name,
        if (items != null) 'items': _encodeItems(items),
        if (description != null) 'description': description,
        if (discountPercent != null)
          'discount_percent': discountPercent.toString(),
        if (startAt != null && startAt.isNotEmpty) 'start_at': startAt,
        if (endAt != null && endAt.isNotEmpty) 'end_at': endAt,
        if (maxPurchases != null) 'max_purchases': maxPurchases.toString(),
      },
      files: {
        if (coverImagePath != null && coverImagePath.isNotEmpty)
          'cover_image': coverImagePath,
      },
    );
  }

  /// DELETE /expert/packages/{id}
  ///
  /// A package that has already been bought is deactivated server-side
  /// rather than removed, so a customer's history keeps resolving.
  Future<void> deletePackage(Object packageId) async {
    await ApiClient.delete(ApiEndpoints.package(packageId));
  }

  /// POST /expert/packages/{id}/toggle
  Future<void> toggleActive(Object packageId) async {
    await ApiClient.post(ApiEndpoints.togglePackage(packageId));
  }

  /// GET /expert/packages/available-items
  ///
  /// Only active services and for-sale products. Raw materials are
  /// filtered server-side, which matters because `products` holds both
  /// and the only thing separating them is `is_for_sale`.
  Future<BundleableItems> getAvailableItems() async {
    final response = await ApiClient.get(ApiEndpoints.packageAvailableItems);
    final payload = ApiResponse.data(response);

    return BundleableItems(
      services: ApiResponse.asMapList(payload['services'])
          .map((row) => ServiceModel(
                id: ApiResponse.asString(row['item_id']),
                name: ApiResponse.asString(row['name']),
                description: '',
                price: ApiResponse.asDouble(row['price']),
                durationMinutes:
                    ApiResponse.asInt(row['duration_minutes']),
              ))
          .toList(),
      products: ApiResponse.asMapList(payload['products'])
          .map((row) => ProductModel(
                id: ApiResponse.asString(row['item_id']),
                name: ApiResponse.asString(row['name']),
                price: ApiResponse.asDouble(row['price']),
                stock: ApiResponse.asDouble(row['stock_quantity']).round(),
                imageUrl: AppConfig.mediaUrl(
                      ApiResponse.asStringOrNull(row['main_image']),
                    ) ??
                    '',
              ))
          .toList(),
    );
  }

  String _encodeItems(List<PackageItemInput> items) {
    final encoded = items
        .map((item) =>
            '{"item_type":"${item.itemType}",'
            '"item_id":${item.itemId},'
            '"quantity":${item.quantity}}')
        .join(',');

    return '[$encoded]';
  }

  PackageModel _toPackage(Map<String, dynamic> row) {
    return PackageModel(
      id: ApiResponse.asString(row['id']),
      name: ApiResponse.asString(row['name']),
      bio: ApiResponse.asString(row['description']),
      // Server-computed from frozen snapshots, never recalculated here.
      totalPrice: ApiResponse.asDouble(row['total_price']),
      discountPercentage: ApiResponse.asDouble(row['discount_percent']),
      startDate: ApiResponse.asDate(row['start_at']),
      endDate: ApiResponse.asDate(row['end_at']),
      includedItemNames: (row['item_names'] is List)
          ? (row['item_names'] as List).map((e) => e.toString()).toList()
          : const [],
      isActive: ApiResponse.asBool(row['is_active'], fallback: true),
      imageUrl: AppConfig.mediaUrl(
        ApiResponse.asStringOrNull(row['cover_image']),
      ),
    );
  }
}

/// One line of a bundle, as sent to the server.
class PackageItemInput {
  const PackageItemInput({
    required this.itemType,
    required this.itemId,
    this.quantity = 1,
  });

  /// `service` or `product`.
  final String itemType;
  final String itemId;
  final int quantity;

  /// Composite key used to track selection in the UI.
  ///
  /// A service id and a product id can both be "3", so a bare id is
  /// ambiguous and would toggle the wrong row.
  String get key => '$itemType:$itemId';

  static PackageItemInput fromKey(String key, {int quantity = 1}) {
    final parts = key.split(':');
    return PackageItemInput(
      itemType: parts.first,
      itemId: parts.length > 1 ? parts[1] : '',
      quantity: quantity,
    );
  }
}

class PackageLine {
  const PackageLine({
    required this.itemType,
    required this.itemId,
    required this.name,
    this.quantity = 1,
    this.unitPrice = 0,
  });

  final String itemType;
  final String itemId;
  final String name;
  final int quantity;

  /// Price frozen when the bundle was saved.
  final double unitPrice;

  String get key => '$itemType:$itemId';

  double get lineTotal => unitPrice * quantity;
}

class PackageDetail {
  const PackageDetail({required this.package, this.items = const []});

  final PackageModel package;
  final List<PackageLine> items;
}

/// What an expert is allowed to put in a bundle.
class BundleableItems {
  const BundleableItems({
    this.services = const [],
    this.products = const [],
  });

  final List<ServiceModel> services;
  final List<ProductModel> products;

  bool get isEmpty => services.isEmpty && products.isEmpty;
}
