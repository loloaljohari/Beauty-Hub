import '../models/product_model.dart';
import '../models/store_metric_model.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Static data source for the Warehouse marketplace and the expert's
/// own "My Store" inventory.
class StoreRepository {
  const StoreRepository();

  /// Products available to buy from the shared warehouse marketplace.
  List<ProductModel> getWarehouseProducts() => const [
        ProductModel(
          id: 'w1',
          imageUrl: 'assets/images/product.png',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
        ),
        ProductModel(
          id: 'w2',
          imageUrl: 'assets/images/product2.png',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
        ),
        ProductModel(
          id: 'w3',
          imageUrl: 'assets/images/product.png',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
        ),
        ProductModel(
          id: 'w4',
          name: 'Serum',
          imageUrl: 'assets/images/product.png',
          price: 5,
          salonName: 'Bariq  salon',
        ),
        ProductModel(
          id: 'w5',
          name: 'Serum',
          imageUrl: 'assets/images/product.png',
          price: 5,
          salonName: 'Bariq  salon',
        ),
        ProductModel(
          id: 'w6',
          name: 'Serum',
          price: 5,
          imageUrl: 'assets/images/product.png',
          salonName: 'Bariq  salon',
        ),
      ];

  /// Products owned/managed by the current expert in their own store.
  List<ProductModel> getMyStoreProducts() => const [
        ProductModel(
          id: 's1',
          name: 'Serum',
          price: 5,
          stock: 20,
          reorderAt: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
        ProductModel(
          id: 's2',
          name: 'Serum',
          price: 5,
          stock: 0,
          reorderAt: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
        ProductModel(
          id: 's3',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
        ProductModel(
          id: 's4',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
        ProductModel(
          id: 's5',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
        ProductModel(
          id: 's6',
          name: 'Serum',
          price: 5,
          salonName: 'Bariq  salon',
          imageUrl: 'assets/images/product.png',
        ),
      ];

  List<StoreMetricModel> getStoreMetrics() => const [
        StoreMetricModel(
          label: 'Products',
          value: '24',
          icon: Icons.inventory_2_outlined,
          accentColor: AppColors.primary,
        ),
        StoreMetricModel(
          label: 'Revenue',
          value: '450\$',
          icon: Icons.payments_outlined,
          accentColor: AppColors.decorativeGold,
        ),
        StoreMetricModel(
          label: 'Orders',
          value: '5',
          icon: Icons.shopping_bag_outlined,
          accentColor: AppColors.decorativeRose,
        ),
      ];
}
