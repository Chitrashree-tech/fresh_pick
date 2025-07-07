import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class VegetablesPage extends StatefulWidget {
  const VegetablesPage({super.key});

  @override
  State<VegetablesPage> createState() => _VegetablesPageState();
}

class _VegetablesPageState extends State<VegetablesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> vegetables = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVegetables();
  }

  Future<void> _loadVegetables() async {
    final response = await supabase.from('vegetables').select().eq('available', true);

    setState(() {
      vegetables = response.map((item) {
        item['qty'] = 0;
        return item;
      }).toList();
      isLoading = false;
    });
  }

  void _updateQty(int index, bool isIncrement) {
    setState(() {
      vegetables[index]["qty"] += isIncrement ? 1 : -1;
      if (vegetables[index]["qty"] < 0) {
        vegetables[index]["qty"] = 0;
      }
    });
  }

  void _addToCart() {
    final cartItems = vegetables
        .where((item) => item["qty"] > 0)
        .map((item) => {
      "name": item["name"],
      "qty": item["qty"],
      "price": item["price"],
    })
        .toList();

    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one vegetable")),
      );
      return;
    }

    for (var item in cartItems) {
      CartService().addCartItem(item);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vegetables added to cart")),
    );
  }

  void _goToCart() {
    final cart = CartService();
    if (cart.cartItems.isEmpty && cart.subscriptions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
    } else {
      Navigator.pushNamed(context, '/cart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: const Text("Vegetables"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (int i = 0; i < vegetables.length; i++) ...[
            _buildVegetableCard(i),
            const SizedBox(height: 20),
          ],
          ElevatedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Add to Cart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegetableCard(int index) {
    final item = vegetables[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.green),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((item["imagePath"] ?? "").isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item["imagePath"],
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported),
              ),
            )
          else
            const Icon(Icons.image, size: 80, color: Colors.grey),

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
          Text(
            "₹${item["price"]}",
            style: const TextStyle(fontSize: 16, color: Colors.green),
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
}
