import 'product.dart';

/// NEW — there was no cart data model at all before. "Add to Cart"
/// buttons across the app had empty onPressed callbacks, and CartScreen
/// only ever rendered its empty state. This model plus CartProvider makes
/// the cart actually work.
///
/// Scoped deliberately: in-memory only, not persisted to a backend, since
/// there's no cart/orders API yet. It resets on app restart. When a cart
/// endpoint exists, CartProvider is the single place that needs to start
/// calling it.
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get lineTotal => product.displayPrice * quantity;
}
