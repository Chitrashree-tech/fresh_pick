import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageVegetablesPage extends StatefulWidget {
  const ManageVegetablesPage({super.key});

  @override
  State<ManageVegetablesPage> createState() => _ManageVegetablesPageState();
}

class _ManageVegetablesPageState extends State<ManageVegetablesPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  List<Map<String, dynamic>> vegetables = [];
  final _formKey = GlobalKey<FormState>();

  String name = "";
  String desc = "";
  int price = 0;
  String imagePath = "";
  bool available = true;

  @override
  void initState() {
    super.initState();
    _fetchVegetables();
  }

  Future<void> _fetchVegetables() async {
    final response = await supabase.from('vegetables').select();
    setState(() {
      vegetables = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _addOrEditVegetable({Map<String, dynamic>? veg}) async {
    if (veg != null) {
      name = veg['name'];
      desc = veg['desc'];
      price = veg['price'];
      imagePath = veg['imagePath'];
      available = veg['available'];
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
        title: Text(veg == null ? "Add Vegetable" : "Edit Vegetable"),
        content: Form(
          key: _formKey,
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: "Vegetable Name"),
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
                final vegData = {
                  "name": name,
                  "desc": desc,
                  "price": price,
                  "imagePath": imagePath,
                  "available": available,
                };

                if (veg == null) {
                  await supabase.from('vegetables').insert(vegData);
                } else {
                  await supabase.from('vegetables').update(vegData).eq('id', veg['id']);
                }

                Navigator.pop(context);
                _fetchVegetables();
              }
            },
            child: Text(veg == null ? "Add" : "Save"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVegetable(int id) async {
    await supabase.from('vegetables').delete().eq('id', id);
    _fetchVegetables();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Vegetables"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Vegetable",
            onPressed: () => _addOrEditVegetable(),
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
            rows: vegetables.map((veg) {
              return DataRow(cells: [
                DataCell(
                  veg["imagePath"] != null && veg["imagePath"].isNotEmpty
                      ? Image.network(
                    veg["imagePath"],
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image),
                  )
                      : const Icon(Icons.image_not_supported),
                ),
                DataCell(Text(veg["name"] ?? "")),
                DataCell(Text(veg["desc"] ?? "")),
                DataCell(Text("₹${veg["price"]}")),
                DataCell(
                  Icon(
                    veg["available"] == true ? Icons.check_circle : Icons.cancel,
                    color: veg["available"] == true ? Colors.green : Colors.red,
                  ),
                ),
                DataCell(Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _addOrEditVegetable(veg: veg),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteVegetable(veg['id']),
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
