class CartService {
  static final CartService _instance = CartService._internal();

  factory CartService() => _instance;

  CartService._internal();

  final List<Map<String, dynamic>> _cartItems = [];
  final List<Map<String, dynamic>> _subscriptions = [];

  // Public getters (read-only view)
  List<Map<String, dynamic>> get cartItems => List.unmodifiable(_cartItems);
  List<Map<String, dynamic>> get subscriptions => List.unmodifiable(_subscriptions);

  // Add or update item in the cart
  void addCartItem(Map<String, dynamic> item) {
    int index = _cartItems.indexWhere((e) => e['name'] == item['name']);
    if (index != -1) {
      _cartItems[index]['qty'] += item['qty'];
    } else {
      _cartItems.add(item);
    }
  }

  // Add subscription
  void addSubscription(Map<String, dynamic> sub) {
    _subscriptions.add(sub);
  }

  // Remove item from cart by index
  void removeCartItemAt(int index) {
    if (index >= 0 && index < _cartItems.length) {
      _cartItems.removeAt(index);
    }
  }

  // Remove subscription by index
  void removeSubscriptionAt(int index) {
    if (index >= 0 && index < _subscriptions.length) {
      _subscriptions.removeAt(index);
    }
  }

  // Clear both lists
  void clear() {
    _cartItems.clear();
    _subscriptions.clear();
  }
}
