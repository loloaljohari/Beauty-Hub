import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/material_item_model.dart';
import 'service_categories_repository.dart';

/// The expert's material inventory - `GET/POST /expert/inventory`.
///
/// Response shape (`InventoryItemResource` + the controller's paginator
/// wrapper):
///   data.items      -> [{id, name, sku, description, category:{...},
///                        price, wholesale_price, stock_quantity,
///                        min_stock_threshold, is_low_stock,
///                        sufficient_for_persons, main_image,
///                        is_active, is_archived, ...}]
///   data.pagination -> {current_page, last_page, per_page, total}
///
/// Two corrections against the previous version:
///
///  1. Archived items were fetched from `GET /expert/inventory/trashed`,
///     which is NOT a registered route. Laravel would match it against
///     `GET /expert/inventory/{item}` with `item = "trashed"` and return
///     404 "المادة غير موجودة". The real mechanism is the
///     `?with_archived=1` query parameter on the index endpoint.
///
///  2. Add/update built their own `http.MultipartRequest` with headers
///     assembled by hand, bypassing every guarantee in [ApiClient]
///     (timeouts, 401 handling, consistent error parsing). They now go
///     through the shared client like everything else.
class MaterialInventoryRepository {
  const MaterialInventoryRepository();

  /// The real `service_categories` list, cached by
  /// [ServiceCategoriesRepository]. Stays synchronous because four
  /// screens read it inside `build()`.
  List<Map<String, dynamic>> getCategories() =>
      ServiceCategoriesRepository.all;

  /// GET /expert/inventory
  Future<List<MaterialItemModel>> getMaterials({
    String? query,
    int? categoryId,
    bool lowStockOnly = false,
    bool withArchived = false,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.inventory,
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
        if (lowStockOnly) 'low_stock': 1,
        if (withArchived) 'with_archived': 1,
        'per_page': 100,
      },
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['items'])
        .map(MaterialItemModel.fromJson)
        .toList();
  }

  /// Archived items only.
  ///
  /// `with_archived=1` returns archived AND active rows together, so the
  /// archived ones are filtered out client-side - the API has no
  /// "archived only" switch.
  Future<List<MaterialItemModel>> getArchivedMaterials() async {
    final response = await ApiClient.get(
      ApiEndpoints.inventory,
      query: {'with_archived': 1, 'per_page': 100},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['items'])
        .where((row) => ApiResponse.asBool(row['is_archived']))
        .map(MaterialItemModel.fromJson)
        .toList();
  }

  /// GET /expert/inventory/{id}
  Future<MaterialItemModel> getMaterial(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.inventoryItem(id));
    final payload = ApiResponse.data(response);

    // The controller returns the resource under `item` on show.
    final item = ApiResponse.asMap(payload['item']);
    return MaterialItemModel.fromJson(item.isEmpty ? payload : item);
  }

  /// POST /expert/inventory (multipart - accepts `main_image`).
  Future<void> addMaterial({
    required String name,
    required String sku,
    required String description,
    required String price,
    required String wholesalePrice,
    required String stockQuantity,
    required double min_stock,
    required int category_id,
    String? imagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.inventory,
      fields: {
        'category_id': category_id.toString(),
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'wholesale_price': wholesalePrice,
        'stock_quantity': stockQuantity,
        'min_stock_threshold': min_stock.toString(),
      },
      files: {
        if (imagePath != null && imagePath.isNotEmpty)
          'main_image': imagePath,
      },
    );
  }

  /// POST /expert/inventory/{id}/update with `_method=PUT`.
  ///
  /// The backend registers this path as `match(['put','post'])`
  /// specifically because multipart does not survive a real PUT on
  /// every client.
  Future<void> updateMaterial({
    required String id,
    required int category_id,
    required String name,
    required String sku,
    required String description,
    required String price,
    required String wholesalePrice,
    required double min_stock,
    required String stockQuantity,
    String? imagePath,
  }) async {
    await ApiClient.putMultipart(
      ApiEndpoints.inventoryUpdate(id),
      fields: {
        'category_id': category_id.toString(),
        'name': name,
        'sku': sku,
        'description': description,
        'price': price,
        'wholesale_price': wholesalePrice,
        'stock_quantity': stockQuantity,
        'min_stock_threshold': min_stock.toString(),
      },
      files: {
        if (imagePath != null && imagePath.isNotEmpty)
          'main_image': imagePath,
      },
    );
  }

  /// DELETE /expert/inventory/{id} - archives rather than hard-deletes.
  Future<void> deleteMaterial(String materialId) async {
    await ApiClient.delete(ApiEndpoints.inventoryItem(materialId));
  }

  /// POST /expert/inventory/{id}/restore
  Future<void> restoreMaterial(String id) async {
    await ApiClient.post(ApiEndpoints.inventoryRestore(id));
  }

  /// GET /expert/inventory/alerts - items at or below their threshold.
  Future<Map<String, dynamic>> getInventoryAlerts() async {
    final response = await ApiClient.get(ApiEndpoints.inventoryAlerts);
    final payload = ApiResponse.data(response);

    return {
      'count': ApiResponse.asInt(payload['count']),
      'items': ApiResponse.asMapList(payload['items'])
          .map(MaterialItemModel.fromJson)
          .toList(),
    };
  }

  /// GET /expert/inventory/smart-alert
  ///
  /// What tomorrow's confirmed bookings will consume, against what is
  /// actually in stock. [date] defaults to tomorrow server-side.
  Future<SmartAlert> getSmartAlert({String? date}) async {
    final response = await ApiClient.get(
      ApiEndpoints.inventorySmartAlert,
      query: {if (date != null) 'date': date},
    );

    final payload = ApiResponse.data(response);

    return SmartAlert(
      date: ApiResponse.asDate(payload['date']),
      bookingsCount: ApiResponse.asInt(payload['bookings_count']),
      shortagesCount: ApiResponse.asInt(payload['shortages_count']),
      materials: ApiResponse.asMapList(payload['materials'])
          .map((row) => SmartAlertMaterial(
                productId: ApiResponse.asString(row['product_id']),
                name: ApiResponse.asString(row['product_name']),
                sku: ApiResponse.asString(row['sku']),
                required: ApiResponse.asDouble(row['required_quantity']),
                available: ApiResponse.asDouble(row['available_quantity']),
                shortage: ApiResponse.asDouble(row['shortage_quantity']),
                isEnough: ApiResponse.asBool(row['is_enough']),
                bookingsCount: ApiResponse.asInt(row['bookings_count']),
              ))
          .toList(),
    );
  }

  /// GET /expert/inventory/{id}/movements -> data.items (paginated)
  Future<List<StockMovement>> getMovements(
    Object itemId, {
    String? movementType,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.inventoryMovements(itemId),
      query: {
        if (movementType != null) 'movement_type': movementType,
        'per_page': 50,
      },
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['items'])
        .map((row) => StockMovement(
              id: ApiResponse.asString(row['id']),
              movementType: ApiResponse.asString(row['movement_type']),
              reason: ApiResponse.asString(row['reason']),
              quantity: ApiResponse.asDouble(row['quantity']),
              notes: ApiResponse.asString(row['notes']),
              createdAt: ApiResponse.asDate(row['created_at']),
            ))
        .toList();
  }

  /// POST /expert/inventory/{id}/movements
  ///
  /// [movementType] is `in` | `out` | `adjustment`.
  /// [reason] must be one of `purchase`, `sale`, `booking_used`,
  /// `return`, `adjustment`, `expired` - the backend validates against
  /// that exact enum.
  ///
  /// Important: for `adjustment` the quantity is the NEW BALANCE, not
  /// a delta. The UI says so explicitly rather than leaving the user
  /// to guess.
  Future<void> addMovement({
    required Object itemId,
    required String movementType,
    required String reason,
    required double quantity,
    String? notes,
  }) async {
    await ApiClient.post(
      ApiEndpoints.inventoryMovements(itemId),
      body: {
        'movement_type': movementType,
        'reason': reason,
        'quantity': quantity,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  // ── derived counters for the header row ─────────────────────────
  // One fetch feeds all three, instead of three separate GETs of the
  // same list as before.

  Future<InventoryCounters> getCounters() async {
    final materials = await getMaterials();

    return InventoryCounters(
      total: materials.length,
      lowStock: materials
          .where((m) => m.quantity > 0 && m.quantity <= m.min_stock)
          .length,
      outOfStock: materials.where((m) => m.quantity == 0).length,
    );
  }

  Future<int> getItemsCount() async => (await getCounters()).total;

  Future<int> getExpiringSoonCount() async => (await getCounters()).lowStock;

  Future<int> getOutOfStockCount() async => (await getCounters()).outOfStock;
}

class InventoryCounters {
  const InventoryCounters({
    this.total = 0,
    this.lowStock = 0,
    this.outOfStock = 0,
  });

  final int total;
  final int lowStock;
  final int outOfStock;
}

/// One row of the stock ledger (`StockMovementResource`).
class StockMovement {
  const StockMovement({
    required this.id,
    required this.movementType,
    required this.reason,
    required this.quantity,
    this.notes = '',
    this.createdAt = '',
  });

  final String id;

  /// `in` | `out` | `adjustment`.
  final String movementType;
  final String reason;
  final double quantity;
  final String notes;
  final String createdAt;

  bool get isIncoming => movementType == 'in';
  bool get isAdjustment => movementType == 'adjustment';
}

/// `GET /expert/inventory/smart-alert` for a single day.
class SmartAlert {
  const SmartAlert({
    this.date = '',
    this.bookingsCount = 0,
    this.shortagesCount = 0,
    this.materials = const [],
  });

  final String date;
  final int bookingsCount;
  final int shortagesCount;
  final List<SmartAlertMaterial> materials;

  bool get hasShortages => shortagesCount > 0;
}

class SmartAlertMaterial {
  const SmartAlertMaterial({
    required this.productId,
    required this.name,
    this.sku = '',
    this.required = 0,
    this.available = 0,
    this.shortage = 0,
    this.isEnough = true,
    this.bookingsCount = 0,
  });

  final String productId;
  final String name;
  final String sku;

  /// What the day's bookings will consume.
  final double required;
  final double available;
  final double shortage;
  final bool isEnough;
  final int bookingsCount;
}
