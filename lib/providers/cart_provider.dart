import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';
import '../models/restaurant.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];
  Restaurant? _currentRestaurant;

  List<CartItem> get items => _items;
  Restaurant? get currentRestaurant => _currentRestaurant;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee => _currentRestaurant?.deliveryFee ?? 0.0;
  
  double get total => subtotal > 0 ? subtotal + deliveryFee : 0.0;

  void addItem(MenuItem menuItem, Restaurant restaurant) {
    if (_currentRestaurant != null && _currentRestaurant!.id != restaurant.id) {
      // Must clear cart if ordering from a different restaurant
      _items.clear();
    }
    _currentRestaurant = restaurant;

    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItem.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
    } else {
      _items.add(CartItem(menuItem: menuItem, restaurant: restaurant));
    }
    notifyListeners();
  }

  void removeItem(String menuItemId) {
    final existingIndex = _items.indexWhere((item) => item.menuItem.id == menuItemId);
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
    }
    if (_items.isEmpty) {
      _currentRestaurant = null;
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _currentRestaurant = null;
    notifyListeners();
  }
}
