import 'package:equatable/equatable.dart';
import '../../data/models/product_model.dart';
import '../../data/models/store_metric_model.dart';

enum MyStoreStatus { initial, loading, loaded, failure }

enum MyStoreActionStatus { idle, loading, success, addedToCart, failure }

class MyStoreState extends Equatable {
  const MyStoreState({
    this.warehouseProducts = const [],
    this.myStoreProducts = const [],
    this.metrics = const [],
    this.tabIndex = 0,
    this.searchQuery = '',
    this.status = MyStoreStatus.initial,
    this.actionStatus = MyStoreActionStatus.idle,
    this.cartCount = 0,
    this.errorMessage,
  });

  final List<ProductModel> warehouseProducts;
  final List<ProductModel> myStoreProducts;
  final List<StoreMetricModel> metrics;
  final int tabIndex;
  final String searchQuery;
  final MyStoreStatus status;
  final MyStoreActionStatus actionStatus;

  /// Lines currently in the cart, for the badge on the cart icon.
  final int cartCount;
  final String? errorMessage;

  List<ProductModel> get filteredWarehouseProducts {
    if (searchQuery.trim().isEmpty) return warehouseProducts;
    final query = searchQuery.toLowerCase();
    return warehouseProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  MyStoreState copyWith({
    List<ProductModel>? warehouseProducts,
    List<ProductModel>? myStoreProducts,
    List<StoreMetricModel>? metrics,
    int? tabIndex,
    String? searchQuery,
    MyStoreStatus? status,
    MyStoreActionStatus? actionStatus,
    int? cartCount,
    String? errorMessage,
  }) {
    return MyStoreState(
      warehouseProducts: warehouseProducts ?? this.warehouseProducts,
      myStoreProducts: myStoreProducts ?? this.myStoreProducts,
      metrics: metrics ?? this.metrics,
      tabIndex: tabIndex ?? this.tabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      status: status ?? this.status,
      actionStatus: actionStatus ?? this.actionStatus,
      cartCount: cartCount ?? this.cartCount,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        warehouseProducts,
        myStoreProducts,
        metrics,
        tabIndex,
        searchQuery,
        status, actionStatus, cartCount, errorMessage];
}
