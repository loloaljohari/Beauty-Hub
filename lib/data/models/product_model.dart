import 'package:equatable/equatable.dart';

/// Stock availability for a product owned by the current expert/salon
/// (shown in "My Store").
enum StockStatus { inStock, lowStock, outOfStock }

/// A product sold either in the shared warehouse marketplace or in
/// the expert's own store.
class ProductModel extends Equatable {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.salonName = '',
    this.imageUrl='',
    this.category = '',
    this.description = '',
    this.stock,
    this.reorderAt,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final double price;
  final String salonName;
  final String imageUrl;
  final String category;
  final String description;

  /// Null when this product is a warehouse listing (not owned stock).
  final int? stock;
  final int? reorderAt;
  final bool isFavorite;

  StockStatus get stockStatus {
    if (stock == null) return StockStatus.inStock;
    if (stock == 0) return StockStatus.outOfStock;
    if (reorderAt != null && stock! <= reorderAt!) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  ProductModel copyWith({bool? isFavorite, int? stock}) {
    return ProductModel(
      id: id,
      name: name,
      price: price,
      salonName: salonName,
      imageUrl: imageUrl,
      category: category,
      description: description,
      stock: stock ?? this.stock,
      reorderAt: reorderAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        price,
        salonName,
        imageUrl,
        category,
        description,
        stock,
        reorderAt,
        isFavorite,
      ];
}
