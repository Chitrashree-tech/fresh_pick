import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/cart_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final supabase = Supabase.instance.client;

  final List<String> availableFruits = [
    "Apple", "Orange", "Pomegranate", "Pineapple", "Papaya", "Cucumber",
    "Watermelon", "Banana", "Grapes", "Kiwi", "Strawberry", "Mango"
  ];

  Map<String, Set<String>> selectedFruits = {
    "Regular Bowl": {},
    "Standard Bowl": {},
  };

  Set<String> selectedBowlNames = {};

  Future<void> _subscribeToSelectedBowls() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please login to subscribe")),
      );
      return;
    }

    for (var bowl in selectedBowlNames) {
      final List<String> fruits = selectedFruits[bowl]!.toList();

      await supabase.from('subscriptions').insert({
        'user_id': user.id,
        'name': bowl,
        'fruits': fruits,
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subscription added successfully")),
    );

    setState(() {
      selectedFruits = {
        "Regular Bowl": {},
        "Standard Bowl": {},
      };
      selectedBowlNames.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      appBar: AppBar(
        title: const Text("Monthly Subscription"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              final List<Map<String, dynamic>> subscriptions = selectedBowlNames.map((bowl) {
                return {
                  "name": bowl,
                  "fruits": selectedFruits[bowl]!.toList(),
                  "startDate": DateTime.now().toString().substring(0, 10),
                };
              }).toList();

              Navigator.pushNamed(
                context,
                '/cart',
                arguments: {
                  'subscriptions': subscriptions,
                  'cartItems': [],
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Choose your monthly plan",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrange,
            ),
          ),
          const SizedBox(height: 16),

          _buildBowlCard(
            bowlName: "Regular Bowl",
            price: "₹1500/month",
            description: "Apple, Orange, Pomegranate, Pineapple, Papaya, Cucumber, Watermelon",
            fruitLimit: 7,
          ),
          const SizedBox(height: 16),
          _buildBowlCard(
            bowlName: "Standard Bowl",
            price: "₹1800/month",
            description: "5 types of fruits, 1 boiled egg, 1 sprout, mixed seeds",
            fruitLimit: 5,
          ),
          const SizedBox(height: 24),

          if (selectedBowlNames.isNotEmpty)
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selected Bowls:",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (var bowl in selectedBowlNames)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bowl,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Fruits: ${selectedFruits[bowl]!.join(', ')}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: selectedBowlNames.isNotEmpty ? _subscribeToSelectedBowls : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text("Subscribe"),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlCard({
    required String bowlName,
    required String price,
    required String description,
    required int fruitLimit,
  }) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: selectedBowlNames.contains(bowlName),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedBowlNames.add(bowlName);
                  } else {
                    selectedBowlNames.remove(bowlName);
                    selectedFruits[bowlName] = {};
                  }
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bowlName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: Text(
          price,
          style: const TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Choose your favorite fruits (Select up to $fruitLimit):",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableFruits.map((fruit) {
                    return FilterChip(
                      label: Text(fruit),
                      selected: selectedFruits[bowlName]!.contains(fruit),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (selectedFruits[bowlName]!.length < fruitLimit) {
                              selectedFruits[bowlName]!.add(fruit);
                            }
                          } else {
                            selectedFruits[bowlName]!.remove(fruit);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
