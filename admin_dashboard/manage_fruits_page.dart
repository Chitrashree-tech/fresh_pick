import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageFruitsPage extends StatefulWidget {
  const ManageFruitsPage({super.key});

  @override
  State<ManageFruitsPage> createState() => _ManageFruitsPageState();
}

class _ManageFruitsPageState extends State<ManageFruitsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> fruits = [];
  final _formKey = GlobalKey<FormState>();

  // Fields for form
  String name = "";
  String desc = "";
  int price = 0;
  String imagePath = "";
  bool available = true;

  @override
  void initState() {
    super.initState();
    _fetchFruits();
  }

  Future<void> _fetchFruits() async {
    final response = await supabase.from('fruits').select();
    setState(() {
      fruits = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addOrEditFruit({Map<String, dynamic>? fruit, int? index}) async {
    if (fruit != null) {
      name = fruit['name'];
      desc = fruit['desc'];
      price = fruit['price'];
      imagePath = fruit['imagePath'];
      available = fruit['available'];
    } else {
      name = "";
      desc = "";
      price = 0;
      imagePath = "";
      available = true;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fruit == null ? "Add Fruit" : "Edit Fruit"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: "Fruit Name"),
                  validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
                  onChanged: (val) => name = val,
                ),
                TextFormField(
                  initialValue: desc,
                  decoration: const InputDecoration(labelText: "Description"),
                  onChanged: (val) => desc = val,
                ),
                TextFormField(
                  initialValue: price > 0 ? price.toString() : "",
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Price per kg"),
                  validator: (val) => val == null || val.isEmpty ? "Enter price" : null,
                  onChanged: (val) => price = int.tryParse(val) ?? 0,
                ),
                TextFormField(
                  initialValue: imagePath,
                  decoration: const InputDecoration(labelText: "Image Path (asset or URL)"),
                  onChanged: (val) => imagePath = val,
                ),
                SwitchListTile(
                  title: const Text("Available"),
                  value: available,
                  onChanged: (val) => setState(() => available = val),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final fruitData = {
                  "name": name,
                  "desc": desc,
                  "price": price,
                  "imagePath": imagePath,
                  "available": available,
                };

                if (fruit == null) {
                  await supabase.from('fruits').insert(fruitData);
                } else if (fruit['id'] != null) {
                  await supabase.from('fruits').update(fruitData).eq('id', fruit['id']);
                }

                Navigator.pop(context);
                _fetchFruits();
              }
            },
            child: Text(fruit == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFruit(int id) async {
    await supabase.from('fruits').delete().eq('id', id);
    _fetchFruits();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Fruits"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Fruit",
            onPressed: () => _addOrEditFruit(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text("Image")),
              DataColumn(label: Text("Name")),
              DataColumn(label: Text("Description")),
              DataColumn(label: Text("Price/kg")),
              DataColumn(label: Text("Available")),
              DataColumn(label: Text("Actions")),
            ],
            rows: fruits.map((fruit) {
              return DataRow(cells: [
                DataCell(
                  fruit["imagePath"] != null && fruit["imagePath"].isNotEmpty
                      ? Image.network(
                    fruit["imagePath"],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.image_not_supported),
                ),
                DataCell(Text(fruit["name"] ?? '')),
                DataCell(Text(fruit["desc"] ?? '')),
                DataCell(Text("₹${fruit["price"]}")),
                DataCell(
                  Icon(
                    fruit["available"] == true ? Icons.check_circle : Icons.cancel,
                    color: fruit["available"] == true ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditFruit(fruit: fruit),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFruit(fruit['id']),
                    ),
                  ],
                )),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}
