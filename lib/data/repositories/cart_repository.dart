import '../models/cart_item_model.dart';
import '../models/product_model.dart';

/// Static data source for the expert's cart when buying from the
/// shared warehouse marketplace.
class CartRepository {
  const CartRepository();

  List<CartItemModel> getCartItems() => const [
        CartItemModel(
          product: ProductModel(
            id: 'w1',
            name: 'Serum',
            price: 5,
            salonName: 'center Bariq',
          ),
          quantity: 3,
          date: '17/5/2026',
          time: '13:30 PM',
        ),
        CartItemModel(
          product: ProductModel(
            id: 'w2',
            name: 'Serum',
            price: 5,
            salonName: 'center Bariq',
          ),
          quantity: 3,
          date: '17/5/2026',
          time: '13:30 PM',
        ),
        CartItemModel(
          product: ProductModel(
            id: 'w3',
            name: 'Serum',
            price: 5,
            salonName: 'center Bariq',
          ),
          quantity: 3,
          date: '17/5/2026',
          time: '13:30 PM',
        ),
      ];
}
