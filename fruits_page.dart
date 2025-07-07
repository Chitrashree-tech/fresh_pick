import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class FruitsPage extends StatefulWidget {
  const FruitsPage({super.key});

  @override
  State<FruitsPage> createState() => _FruitsPageState();
}

class _FruitsPageState extends State<FruitsPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> fruits = [];
  final List<double> weightOptions = [0.25, 0.5, 1.0];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFruits();
  }

  Future<void> _loadFruits() async {
    final response = await supabase.from('fruits').select().eq('available', true);

    setState(() {
      fruits = response.map((item) {
        item['qty'] = 0;
        item['weight'] = 1.0;
        return item;
      }).toList();
      isLoading = false;
    });
  }

  void _updateQty(int index, bool isIncrement) {
    setState(() {
      fruits[index]["qty"] += isIncrement ? 1 : -1;
      if (fruits[index]["qty"] < 0) {
        fruits[index]["qty"] = 0;
      }
    });
  }

  void _updateWeight(int index, double newWeight) {
    setState(() {
      fruits[index]["weight"] = newWeight;
    });
  }

  void _addToCart() {
    final cart = CartService();
    final itemsToAdd = fruits
        .where((item) => item["qty"] > 0)
        .map((item) => {
      "name": item["name"],
      "qty": item["qty"],
      "weight": item["weight"],
      "price": (item["price"] * item["weight"]).toInt(),
    })
        .toList();

    if (itemsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one fruit")),
      );
      return;
    }

    for (var item in itemsToAdd) {
      cart.addCartItem(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fruits added to cart")),
    );
  }

  Widget _buildSubscriptionLinkSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Save more with a monthly subscription!",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/subscription');
            },
            child: const Text(
              "Explore monthly plans →",
              style: TextStyle(
                fontSize: 16,
                color: Colors.deepOrange,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitCard(int index) {
    final item = fruits[index];
    final double selectedWeight = item["weight"];
    final int pricePerKg = item["price"];
    final int displayPrice = (pricePerKg * selectedWeight).toInt();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.deepOrange),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item["imagePath"] ?? "",
              height: 90,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 90,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.image_not_supported, color: Colors.grey)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item["name"],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            item["desc"],
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text("Select weight: ", style: TextStyle(fontSize: 14)),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: weightOptions.map((w) {
                      return Row(
                        children: [
                          Radio<double>(
                            value: w,
                            groupValue: selectedWeight,
                            onChanged: (value) {
                              if (value != null) _updateWeight(index, value);
                            },
                          ),
                          Text(w == 1.0 ? "1kg" : "${(w * 1000).toInt()}g", style: const TextStyle(fontSize: 14)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "₹$displayPrice for ${selectedWeight == 1.0 ? "1kg" : "${(selectedWeight * 1000).toInt()}g"}",
            style: const TextStyle(fontSize: 16, color: Colors.deepOrange),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _updateQty(index, false),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text('${item["qty"]}', style: const TextStyle(fontSize: 16)),
              IconButton(
                onPressed: () => _updateQty(index, true),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService();

    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Fruits"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              if (cart.cartItems.isEmpty && cart.subscriptions.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cart is empty")),
                );
              } else {
                Navigator.pushNamed(context, '/cart');
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSubscriptionLinkSection(),
          for (int i = 0; i < fruits.length; i++) ...[
            _buildFruitCard(i),
            const SizedBox(height: 20),
          ],
          ElevatedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Add to Cart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
