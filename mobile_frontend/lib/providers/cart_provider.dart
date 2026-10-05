import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

/// NEW. There was no cart state anywhere in the app — "Add to Cart" was
/// wired to an empty callback and CartScreen unconditionally rendered its
/// empty state. This makes the cart real.
///
/// Deliberately in-memory only: there's no cart/orders endpoint yet to
/// persist to. When one exists, this is the single place that needs to
/// start calling it — every screen already goes through this provider.
class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {}; // keyed by product.id

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
  double get subtotal => _items.values.fold(0.0, (sum, item) => sum + item.lineTotal);
  bool get isEmpty => _items.isEmpty;

  void addProduct(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += quantity;
    } else {
      _items[product.id] = CartItem(product: product, quantity: quantity);
    }
    notifyListeners();
  }

  void incrementQuantity(int productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity++;
      notifyListeners();
    }
  }

  void decrementQuantity(int productId) {
    final item = _items[productId];
    if (item == null) return;
    if (item.quantity <= 1) {
      _items.remove(productId);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }

  void removeProduct(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
