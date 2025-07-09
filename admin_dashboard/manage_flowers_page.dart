import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageFlowersPage extends StatefulWidget {
  const ManageFlowersPage({super.key});

  @override
  State<ManageFlowersPage> createState() => _ManageFlowersPageState();
}

class _ManageFlowersPageState extends State<ManageFlowersPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> flowers = [];
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String desc = "";
  int price = 0;
  String imagePath = "";
  bool available = true;

  @override
  void initState() {
    super.initState();
    _fetchFlowers();
  }

  Future<void> _fetchFlowers() async {
    final response = await supabase.from('flowers').select();
    setState(() {
      flowers = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addOrEditFlower({Map<String, dynamic>? flower}) async {
    if (flower != null) {
      name = flower['name'];
      desc = flower['desc'];
      price = flower['price'];
      imagePath = flower['imagePath'];
      available = flower['available'];
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
        title: Text(flower == null ? "Add Flower" : "Edit Flower"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: "Flower Name"),
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
                  decoration: const InputDecoration(labelText: "Price per piece"),
                  validator: (val) => val == null || val.isEmpty ? "Enter price" : null,
                  onChanged: (val) => price = int.tryParse(val) ?? 0,
                ),
                TextFormField(
                  initialValue: imagePath,
                  decoration: const InputDecoration(labelText: "Image Path"),
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
                final flowerData = {
                  "name": name,
                  "desc": desc,
                  "price": price,
                  "imagePath": imagePath,
                  "available": available,
                };

                if (flower == null) {
                  await supabase.from('flowers').insert(flowerData);
                } else {
                  await supabase.from('flowers').update(flowerData).eq('id', flower['id']);
                }

                Navigator.pop(context);
                _fetchFlowers();
              }
            },
            child: Text(flower == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFlower(int id) async {
    await supabase.from('flowers').delete().eq('id', id);
    _fetchFlowers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Flowers"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Flower",
            onPressed: () => _addOrEditFlower(),
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
              DataColumn(label: Text("Price/piece")),
              DataColumn(label: Text("Available")),
              DataColumn(label: Text("Actions")),
            ],
            rows: flowers.map((flower) {
              return DataRow(cells: [
                DataCell(
                  flower["imagePath"] != null && flower["imagePath"].isNotEmpty
                      ? Image.network(
                    flower["imagePath"],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.image_not_supported),
                ),
                DataCell(Text(flower["name"] ?? "")),
                DataCell(Text(flower["desc"] ?? "")),
                DataCell(Text("₹${flower["price"]}")),
                DataCell(
                  Icon(
                    flower["available"] == true ? Icons.check_circle : Icons.cancel,
                    color: flower["available"] == true ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditFlower(flower: flower),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFlower(flower['id']),
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
