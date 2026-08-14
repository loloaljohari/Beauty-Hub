import '../../core/config/app_config.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../core/network/api_response.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

/// Commerce for the expert, in both directions.
///
///   BUYER  - `/expert/shop/*`  : warehouse catalogue, cart, own orders
///   SELLER - `/expert/store/*` : storefront CRUD, incoming orders
///
/// These endpoints only exist after the polymorphic-commerce migration:
/// `cart.user_id` and `orders.user_id` were foreign keys to `users`, so
/// an expert could not own a cart or place an order at all. Everything
/// here fails with a 404 against an older backend.
class ShopRepository {
  const ShopRepository();

  // ── buyer: catalogue ────────────────────────────────────────────

  /// GET /expert/shop/products -> data.products
  Future<List<ProductModel>> getWarehouseProducts({
    String? query,
    int? categoryId,
  }) async {
    final response = await ApiClient.get(
      ApiEndpoints.shopProducts,
      query: {
        if (query != null && query.isNotEmpty) 'q': query,
        if (categoryId != null) 'category_id': categoryId,
      },
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['products'])
        .map(_toProduct)
        .toList();
  }

  /// GET /expert/shop/products/{id} -> data.product
  Future<ProductDetail> getWarehouseProduct(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.shopProduct(id));
    final row = ApiResponse.object(response, 'product');

    return ProductDetail(
      product: _toProduct(row),
      sellerRating: ApiResponse.asDouble(row['seller_rating']),
      images: [
        // `images` is already absolute from the API; `main_image` is the
        // fallback so a product with one photo still has a gallery.
        ...(row['images'] is List
            ? (row['images'] as List)
                .map((e) => AppConfig.mediaUrl(e?.toString()))
                .whereType<String>()
            : const <String>[]),
      ],
    );
  }

  // ── buyer: cart ─────────────────────────────────────────────────

  /// Every cart mutation returns the whole cart, so the caller never
  /// has to guess the new total.
  Future<CartBundle> getCart() async {
    return _toCart(await ApiClient.get(ApiEndpoints.shopCart));
  }

  Future<CartBundle> addToCart({
    required Object productId,
    int quantity = 1,
  }) async {
    return _toCart(await ApiClient.post(
      ApiEndpoints.shopCartItems,
      body: {'product_id': productId, 'quantity': quantity},
    ));
  }

  /// Sending 0 removes the line - that is what the stepper does when
  /// the user taps minus at a quantity of one.
  Future<CartBundle> updateCartItem({
    required Object cartItemId,
    required int quantity,
  }) async {
    return _toCart(await ApiClient.put(
      ApiEndpoints.shopCartItem(cartItemId),
      body: {'quantity': quantity},
    ));
  }

  Future<CartBundle> removeCartItem(Object cartItemId) async {
    return _toCart(await ApiClient.delete(
      ApiEndpoints.shopCartItem(cartItemId),
    ));
  }

  /// POST /expert/shop/cart/checkout -> data.order
  ///
  /// Creates one order and empties the cart. Stock is not deducted
  /// until the seller confirms.
  Future<OrderModel> checkout({String? notes}) async {
    final response = await ApiClient.post(
      ApiEndpoints.shopCheckout,
      body: {if (notes != null && notes.isNotEmpty) 'notes': notes},
    );

    return _toOrder(
      ApiResponse.object(response, 'order'),
      OrderRole.buyerWarehouse,
    );
  }

  // ── buyer: orders ───────────────────────────────────────────────

  Future<List<OrderModel>> getMyOrders({String? status}) async {
    final response = await ApiClient.get(
      ApiEndpoints.shopOrders,
      query: {if (status != null) 'status': status},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['orders'])
        .map((row) => _toOrder(row, OrderRole.buyerWarehouse))
        .toList();
  }

  Future<OrderModel> getMyOrder(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.shopOrder(id));
    return _toOrder(
      ApiResponse.object(response, 'order'),
      OrderRole.buyerWarehouse,
    );
  }

  Future<OrderModel> cancelMyOrder(Object id) async {
    final response = await ApiClient.post(ApiEndpoints.cancelShopOrder(id));
    return _toOrder(
      ApiResponse.object(response, 'order'),
      OrderRole.buyerWarehouse,
    );
  }

  // ── seller: storefront ──────────────────────────────────────────

  Future<List<ProductModel>> getStoreProducts({String? query}) async {
    final response = await ApiClient.get(
      ApiEndpoints.storeProducts,
      query: {if (query != null && query.isNotEmpty) 'q': query},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['products'])
        .map(_toProduct)
        .toList();
  }

  /// POST /expert/store/products (multipart - accepts `main_image`).
  ///
  /// `sku` is required and unique per provider, so two experts may use
  /// the same code without clashing.
  Future<void> createStoreProduct({
    required String name,
    required String sku,
    required double price,
    String? description,
    double? wholesalePrice,
    double? stockQuantity,
    double? minStockThreshold,
    int? categoryId,
    String? imagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.storeProducts,
      fields: {
        'name': name,
        'sku': sku,
        'price': price.toString(),
        if (description != null && description.isNotEmpty)
          'description': description,
        if (wholesalePrice != null)
          'wholesale_price': wholesalePrice.toString(),
        if (stockQuantity != null) 'stock_quantity': stockQuantity.toString(),
        if (minStockThreshold != null)
          'min_stock_threshold': minStockThreshold.toString(),
        if (categoryId != null) 'category_id': categoryId.toString(),
      },
      files: {
        if (imagePath != null && imagePath.isNotEmpty)
          'main_image': imagePath,
      },
    );
  }

  /// POST /expert/store/products/{id} - registered as
  /// `match(['put','post'])` so multipart survives.
  Future<void> updateStoreProduct({
    required Object productId,
    Map<String, String> fields = const {},
    String? imagePath,
  }) async {
    await ApiClient.postMultipart(
      ApiEndpoints.storeProduct(productId),
      fields: fields,
      files: {
        if (imagePath != null && imagePath.isNotEmpty)
          'main_image': imagePath,
      },
    );
  }

  /// DELETE /expert/store/products/{id}
  ///
  /// The server archives rather than deletes, because `order_items`
  /// references the row and a hard delete would take buyers' order
  /// history with it.
  Future<void> deleteStoreProduct(Object productId) async {
    await ApiClient.delete(ApiEndpoints.storeProduct(productId));
  }

  // ── seller: incoming orders ─────────────────────────────────────

  Future<List<OrderModel>> getStoreOrders({String? status}) async {
    final response = await ApiClient.get(
      ApiEndpoints.storeOrders,
      query: {if (status != null) 'status': status},
    );

    return ApiResponse.asMapList(ApiResponse.data(response)['orders'])
        .map((row) => _toOrder(row, OrderRole.sellerStore))
        .toList();
  }

  Future<OrderModel> getStoreOrder(Object id) async {
    final response = await ApiClient.get(ApiEndpoints.storeOrder(id));
    return _toOrder(
      ApiResponse.object(response, 'order'),
      OrderRole.sellerStore,
    );
  }

  /// PUT /expert/store/orders/{id}/status
  ///
  /// The backend only allows forward moves along
  /// pending -> confirmed -> processing -> shipped -> delivered, plus a
  /// cancel before shipping. Anything else returns a 422.
  Future<OrderModel> updateStoreOrderStatus({
    required Object orderId,
    required String status,
  }) async {
    final response = await ApiClient.put(
      ApiEndpoints.storeOrderStatus(orderId),
      body: {'status': status},
    );

    return _toOrder(
      ApiResponse.object(response, 'order'),
      OrderRole.sellerStore,
    );
  }

  // ── mapping ─────────────────────────────────────────────────────

  ProductModel _toProduct(Map<String, dynamic> row) {
    final stock = ApiResponse.asDouble(row['stock_quantity']);

    return ProductModel(
      id: ApiResponse.asString(row['id']),
      name: ApiResponse.asString(row['name']),
      price: ApiResponse.asDouble(row['price']),
      salonName: ApiResponse.asString(row['seller_name']),
      // Already absolute from the API, but run through mediaUrl anyway
      // so a relative path from an older build still resolves.
      imageUrl:
          AppConfig.mediaUrl(ApiResponse.asStringOrNull(row['main_image'])) ??
              '',
      description: ApiResponse.asString(row['description']),
      stock: stock.round(),
    );
  }

  CartBundle _toCart(dynamic response) {
    final payload = ApiResponse.data(response);

    return CartBundle(
      total: ApiResponse.asDouble(payload['total']),
      items: ApiResponse.asMapList(payload['items'])
          .map((row) => CartLine(
                cartItemId: ApiResponse.asString(row['cart_item_id']),
                inStock: ApiResponse.asBool(row['in_stock'], fallback: true),
                item: CartItemModel(
                  quantity: ApiResponse.asInt(row['quantity']),
                  product: ProductModel(
                    id: ApiResponse.asString(row['product_id']),
                    name: ApiResponse.asString(row['name']),
                    price: ApiResponse.asDouble(row['unit_price']),
                    salonName: ApiResponse.asString(row['seller_name']),
                    imageUrl: AppConfig.mediaUrl(
                          ApiResponse.asStringOrNull(row['main_image']),
                        ) ??
                        '',
                    stock: ApiResponse.asDouble(row['stock_quantity']).round(),
                  ),
                ),
              ))
          .toList(),
    );
  }

  OrderModel _toOrder(Map<String, dynamic> row, OrderRole role) {
    final buyer = ApiResponse.asMap(row['buyer']);
    final createdAt = ApiResponse.asString(row['created_at']);
    final status = _toStatus(ApiResponse.asString(row['status']));

    final items = ApiResponse.asMapList(row['items'])
        .map((item) => CartItemModel(
              quantity: ApiResponse.asInt(item['quantity']),
              product: ProductModel(
                id: ApiResponse.asString(item['product_id']),
                name: ApiResponse.asString(item['name']),
                price: ApiResponse.asDouble(item['unit_price']),
                imageUrl: AppConfig.mediaUrl(
                      ApiResponse.asStringOrNull(item['main_image']),
                    ) ??
                    '',
              ),
            ))
        .toList();

    return OrderModel(
      id: ApiResponse.asString(row['id']),
      role: role,
      items: items,
      date: _datePart(createdAt),
      time: _timePart(createdAt),
      counterpartyName: ApiResponse.asString(buyer['name']),
      // Delivery address, or the buyer's city when no address was
      // attached at checkout.
      location: ApiResponse.asString(buyer['location']),
      status: status,
      timeline: _timelineFor(status, createdAt,
          ApiResponse.asString(row['updated_at'])),
      // The API sends a seller-scoped total for store orders, which the
      // model would otherwise recompute from items alone.
      serverTotal: ApiResponse.asDouble(row['total']),
    );
  }

  /// The API's status vocabulary is wider than the app's enum.
  /// `pending` and `confirmed` both read as "approved" to the user;
  /// `processing` maps to "packed".
  OrderStatus _toStatus(String raw) {
    switch (raw) {
      case 'processing':
        return OrderStatus.packed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'returned':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.approved;
    }
  }

  /// The backend keeps no per-status history table, only `created_at`
  /// and `updated_at`. The timeline is therefore derived: steps up to
  /// the current status are marked done, later ones are pending. Dates
  /// beyond the first and last are genuinely unknown and left blank
  /// rather than invented.
  List<OrderTimelineStep> _timelineFor(
    OrderStatus status,
    String createdAt,
    String updatedAt,
  ) {
    const order = [
      OrderStatus.approved,
      OrderStatus.packed,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    if (status == OrderStatus.cancelled) {
      return [
        OrderTimelineStep(
          status: OrderStatus.approved,
          dateLabel: _dateLabel(createdAt),
        ),
        OrderTimelineStep(
          status: OrderStatus.cancelled,
          dateLabel: _dateLabel(updatedAt),
        ),
      ];
    }

    final currentIndex = order.indexOf(status);

    return [
      for (var i = 0; i < order.length; i++)
        OrderTimelineStep(
          status: order[i],
          dateLabel: i == 0
              ? _dateLabel(createdAt)
              : i == currentIndex
                  ? _dateLabel(updatedAt)
                  : i < currentIndex
                      ? ''
                      : null,
        ),
    ];
  }

  String _datePart(String iso) =>
      iso.contains('T') ? iso.split('T').first : iso.split(' ').first;

  String _timePart(String iso) {
    final parts = iso.contains('T') ? iso.split('T') : iso.split(' ');
    if (parts.length < 2) return '';
    return parts[1].length >= 5 ? parts[1].substring(0, 5) : parts[1];
  }

  String _dateLabel(String iso) {
    final date = _datePart(iso);
    final time = _timePart(iso);
    return time.isEmpty ? date : '$date | $time';
  }
}

/// Warehouse product plus the extras only the detail screen needs.
class ProductDetail {
  const ProductDetail({
    required this.product,
    this.sellerRating = 0,
    this.images = const [],
  });

  final ProductModel product;
  final double sellerRating;
  final List<String> images;
}

/// One cart line. [cartItemId] is the row id used to update or remove
/// it - distinct from the product id.
class CartLine {
  const CartLine({
    required this.cartItemId,
    required this.item,
    this.inStock = true,
  });

  final String cartItemId;
  final CartItemModel item;

  /// False when the seller's stock has dropped below this quantity
  /// since it was added; checkout will be rejected until it is fixed.
  final bool inStock;
}

class CartBundle {
  const CartBundle({this.items = const [], this.total = 0});

  final List<CartLine> items;
  final double total;

  bool get isEmpty => items.isEmpty;

  /// True when at least one line can no longer be fulfilled.
  bool get hasStockIssue => items.any((line) => !line.inStock);
}