import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Map<String, dynamic>> get subscriptions => CartService().subscriptions;
  List<Map<String, dynamic>> get cartItems => CartService().cartItems;

  void removeSubscription(int index) {
    setState(() {
      CartService().removeSubscriptionAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription removed')),
    );
  }

  void removeCartItem(int index) {
    setState(() {
      CartService().removeCartItemAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Item removed from cart')),
    );
  }

  int calculateTotalPrice() {
    int total = 0;
    for (var sub in subscriptions) {
      if (sub['name'] == "Regular Bowl") total += 1500;
      if (sub['name'] == "Standard Bowl") total += 1800;
    }
    for (var item in cartItems) {
      int qty = item['qty'] ?? 1;
      int price = item['price'] ?? 0;
      total += price * qty;
    }
    return total;
  }

  Future<void> placeOrder() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to place order.")),
      );
      return;
    }

    try {
      // Insert subscriptions
      for (final sub in subscriptions) {
        await supabase.from('orders').insert({
          'user_id': user.id,
          'item_name': sub['name'],
          'quantity': 1,
          'price': sub['name'] == 'Regular Bowl' ? 1500 : 1800,
          'type': 'subscription',
        });
      }

      // Insert cart items
      for (final item in cartItems) {
        await supabase.from('orders').insert({
          'user_id': user.id,
          'item_name': item['name'],
          'quantity': item['qty'],
          'price': item['price'],
          'type': 'cart',
        });
      }

      CartService().clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order placed successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error placing order: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("My Cart"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: (subscriptions.isEmpty && cartItems.isEmpty)
          ? _buildEmptyCart()
          : _buildCartContents(),
    );
  }

  Widget _buildEmptyCart() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 64, color: Colors.deepOrange),
          const SizedBox(height: 20),
          const Text("Your cart is empty!",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Add items from fruits, vegetables, or flowers."),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            icon: const Icon(Icons.shopping_bag),
            label: const Text("Continue Shopping"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContents() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          if (subscriptions.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Your Subscriptions",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                ),
                ...subscriptions.asMap().entries.map(
                      (entry) => SubscriptionCard(
                    sub: entry.value,
                    onCancel: () => removeSubscription(entry.key),
                  ),
                ),
              ],
            ),
          if (cartItems.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text("Your Items",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange)),
                ),
                ...cartItems.asMap().entries.map(
                      (entry) => CartItemCard(
                    item: entry.value,
                    onDelete: () => removeCartItem(entry.key),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          Text("Total: ₹${calculateTotalPrice()}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: placeOrder,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Proceed to Checkout"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 18),
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final Map<String, dynamic> sub;
  final VoidCallback onCancel;

  const SubscriptionCard({super.key, required this.sub, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final List<String> fruits = (sub["fruits"] as List<dynamic>).cast<String>();

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(sub["name"], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Fruits: ${fruits.join(', ')}\nStart: ${sub["startDate"]}"),
        trailing: IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: onCancel,
        ),
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onDelete;

  const CartItemCard({super.key, required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(item["name"]),
        subtitle: Text("Qty: ${item["qty"]}"),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
