import 'package:flutter/material.dart';

class RequestInventoryPage extends StatelessWidget {
  const RequestInventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> nearbyWorkshops = [
      {
        'name': 'Sri Auto Workshop',
        'contact': 'sri.auto@example.com',
        'phone': '011-23334455',
        'address': 'Jalan Beserah, Kuantan, Pahang',
        'distance': 4.2,
        'inventory': [
          {'name': 'Brake Pad', 'price': 150.00, 'quantity': 10},
          {'name': 'Air Filter', 'price': 45.00, 'quantity': 25},
        ],
      },
      {
        'name': 'Sahabat Motor',
        'contact': 'sahabatmotor@gmail.com',
        'phone': '013-8899776',
        'address': 'Lorong Seri Kuantan 2, Kuantan, Pahang',
        'distance': 7.8,
        'inventory': [
          {'name': 'Engine Oil 4L', 'price': 120.00, 'quantity': 40},
          {'name': 'Spark Plug', 'price': 25.00, 'quantity': 60},
        ],
      },
      {
        'name': 'Bersatu Workshop',
        'contact': '019-7766554',
        'phone': '',
        'address': 'Jalan Gambang, Kuantan, Pahang',
        'distance': 9.5,
        'inventory': [
          {'name': 'Timing Belt', 'price': 300.00, 'quantity': 7},
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Request Inventory")),
      body: ListView.builder(
        itemCount: nearbyWorkshops.length,
        itemBuilder: (context, index) {
          final workshop = nearbyWorkshops[index];
          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: ListTile(
              title: Text(workshop['name']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (workshop['phone'] != '')
                    Text('Phone: ${workshop['phone']}'),
                  if (workshop['contact'] != '')
                    Text('Email: ${workshop['contact']}'),
                  Text('Address: ${workshop['address']}'),
                  Text('Distance: ${workshop['distance']} km'),
                ],
              ),
              isThreeLine: true,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => InventoryRequestDialog(workshop: workshop),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class InventoryRequestDialog extends StatefulWidget {
  final Map<String, dynamic> workshop;

  const InventoryRequestDialog({super.key, required this.workshop});

  @override
  State<InventoryRequestDialog> createState() =>
      _InventoryRequestDialogState();
}

class _InventoryRequestDialogState extends State<InventoryRequestDialog> {
  final Map<String, TextEditingController> quantityControllers = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.workshop['inventory']) {
      quantityControllers[item['name']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (var controller in quantityControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void submitRequest() {
    final orderedItems = <Map<String, dynamic>>[];

    for (var item in widget.workshop['inventory']) {
      final name = item['name'];
      final qtyText = quantityControllers[name]!.text.trim();
      final qty = int.tryParse(qtyText) ?? 0;

      if (qty > 0 && qty <= item['quantity']) {
        orderedItems.add({
          'name': name,
          'price': item['price'],
          'quantity': qty,
        });
      } else if (qty > item['quantity']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "You cannot order more than available quantity for $name.",
            ),
          ),
        );
        return;
      }
    }

    if (orderedItems.isNotEmpty) {
      Navigator.pop(context); // Close the request dialog

      Future.delayed(const Duration(milliseconds: 100), () {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text("Request Submitted"),
              content: Text(
                "You have requested ${orderedItems.length} item(s) from ${widget.workshop['name']}",
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext); // Close confirmation dialog
                    Navigator.pushReplacement(
                      dialogContext,
                      MaterialPageRoute(
                        builder: (_) => const RequestInventoryPage(),
                      ),
                    );
                  },
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter quantity to order.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Request Items from ${widget.workshop['name']}'),
      content: SingleChildScrollView(
        child: Column(
          children: widget.workshop['inventory'].map<Widget>((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('RM ${item['price'].toStringAsFixed(2)}'),
                        Text('Available: ${item['quantity']}'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: quantityControllers[item['name']],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Qty",
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: submitRequest,
          child: const Text("Submit"),
        ),
      ],
    );
  }
}
