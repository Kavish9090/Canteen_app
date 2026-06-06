import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, OrderCartItem> _items = {};
  final Map<String, int> _prepTimes = {};

  Map<String, OrderCartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    var total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  int get estimatedPrepTime {
    if (_items.isEmpty) return 0;
    int maxPrep = 0;
    _items.forEach((key, item) {
      int itemPrep = _prepTimes[key] ?? 5;
      if (itemPrep > maxPrep) {
        maxPrep = itemPrep;
      }
    });
    return maxPrep;
  }

  void addItem(MenuItemModel menuItem) {
    if (_items.containsKey(menuItem.id)) {
      _items.update(
        menuItem.id,
        (existing) => OrderCartItem(
          productId: existing.productId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        menuItem.id,
        () => OrderCartItem(
          productId: menuItem.id,
          name: menuItem.name,
          price: menuItem.price,
          quantity: 1,
        ),
      );
      _prepTimes[menuItem.id] = menuItem.preparationTime;
    }
    notifyListeners();
  }

  void decreaseQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => OrderCartItem(
          productId: existing.productId,
          name: existing.name,
          price: existing.price,
          quantity: existing.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
      _prepTimes.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _prepTimes.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _prepTimes.clear();
    notifyListeners();
  }
}
