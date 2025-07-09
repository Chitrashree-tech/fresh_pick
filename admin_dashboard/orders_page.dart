import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> orders = [];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    final response = await supabase.from('orders').select();
    setState(() {
      orders = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _updateOrderStatus(int index, String status) async {
    final order = orders[index];
    await supabase.from('orders').update({
      "status": status,
    }).eq('id', order['id']);

    _fetchOrders(); // refresh after update
  }

  String _formatTime(String timeString) {
    final time = DateTime.parse(timeString).toLocal();
    return "${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Orders"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Text(order["customer"][0]),
              ),
              title: Text("Order ID: ${order["id"]}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Customer: ${order["customer"]}"),
                  Text("Items: ${List<String>.from(order["items"]).join(', ')}"),
                  Text("Total: ₹${order["total"]}"),
                  Text("Time: ${_formatTime(order["timestamp"])}"),
                  Text("Status: ${order["status"]}"),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _updateOrderStatus(index, value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "Pending", child: Text("Pending")),
                  PopupMenuItem(value: "Processing", child: Text("Processing")),
                  PopupMenuItem(value: "Delivered", child: Text("Delivered")),
                  PopupMenuItem(value: "Cancelled", child: Text("Cancelled")),
                ],
                icon: const Icon(Icons.more_vert),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
