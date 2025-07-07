import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class FlowersPage extends StatefulWidget {
  const FlowersPage({super.key});

  @override
  State<FlowersPage> createState() => _FlowersPageState();
}

class _FlowersPageState extends State<FlowersPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> flowers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlowers();
  }

  Future<void> _loadFlowers() async {
    final response =
    await supabase.from('flowers').select().eq('available', true);

    setState(() {
      flowers = response.map((item) {
        item['qty'] = 0;
        return item;
      }).toList();
      isLoading = false;
    });
  }

  void _updateQty(int index, bool isIncrement) {
    setState(() {
      flowers[index]["qty"] += isIncrement ? 1 : -1;
      if (flowers[index]["qty"] < 0) {
        flowers[index]["qty"] = 0;
      }
    });
  }

  void _addToCart() {
    final itemsToAdd = flowers
        .where((item) => item["qty"] > 0)
        .map((item) => {
      "name": item["name"],
      "qty": item["qty"],
      "price": item["price"],
    })
        .toList();

    if (itemsToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one flower item")),
      );
      return;
    }

    for (var item in itemsToAdd) {
      CartService().addCartItem(item);
    }

    setState(() {
      for (var flower in flowers) {
        flower["qty"] = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Flowers added to cart")),
    );
  }

  void _goToCart() {
    Navigator.pushNamed(
      context,
      '/cart',
      arguments: {
        'subscriptions': CartService().subscriptions,
        'cartItems': CartService().cartItems,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[50],
      appBar: AppBar(
        title: const Text("Flowers"),
        backgroundColor: Colors.purple,
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
          for (int i = 0; i < flowers.length; i++) ...[
            _buildFlowerCard(i),
            const SizedBox(height: 20),
          ],
          ElevatedButton.icon(
            onPressed: _addToCart,
            icon: const Icon(Icons.shopping_cart_checkout),
            label: const Text("Add to Cart"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowerCard(int index) {
    final item = flowers[index];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.purple),
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
            style: const TextStyle(fontSize: 16, color: Colors.purple),
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
