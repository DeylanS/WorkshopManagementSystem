import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../models/inventory.dart';
import '../../providers/inventory_provider.dart';
import '../../data/sample_data.dart'; // For categorySupplierMap and carModelCompatibilityMap

class UpdateInventoryPage extends StatefulWidget {
  final Inventory itemToUpdate;

  const UpdateInventoryPage({super.key, required this.itemToUpdate});

  @override
  State<UpdateInventoryPage> createState() => _UpdateInventoryPageState();
}

class _UpdateInventoryPageState extends State<UpdateInventoryPage> {
  late TextEditingController nameController;
  late TextEditingController partNumberController;
  late TextEditingController quantityController;
  late TextEditingController sellingPriceController;
  late TextEditingController costPriceController;
  late TextEditingController orderDateController;
  late TextEditingController minStockController;

  String selectedCategory = '';
  String selectedSupplier = '';
  String selectedCarModel = '';
  String compatibilityInfo = '';
  File? selectedImage;

  bool isLoading = false;
  bool showDeleteConfirmation = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.itemToUpdate.name);
    partNumberController = TextEditingController(
      text: widget.itemToUpdate.partNumber,
    );
    quantityController = TextEditingController(
      text: widget.itemToUpdate.quantity.toString(),
    );
    sellingPriceController = TextEditingController(
      text: widget.itemToUpdate.price.toString(),
    );
    costPriceController = TextEditingController(
      text: widget.itemToUpdate.costPrice.toString(),
    );
    orderDateController = TextEditingController(
      text: widget.itemToUpdate.orderDate,
    );
    minStockController = TextEditingController(
      text: widget.itemToUpdate.minStockLevel.toString(),
    );

    selectedCategory = widget.itemToUpdate.category;
    selectedSupplier = widget.itemToUpdate.supplier;
    selectedCarModel = widget.itemToUpdate.carModel;
    compatibilityInfo = carModelCompatibilityMap[selectedCarModel] ?? 'No info';
  }

  Future<void> onSave() async {
    setState(() => isLoading = true);

    widget.itemToUpdate.name = nameController.text.trim();
    widget.itemToUpdate.partNumber = partNumberController.text.trim();
    widget.itemToUpdate.quantity =
        int.tryParse(quantityController.text.trim()) ?? 0;
    widget.itemToUpdate.price =
        double.tryParse(sellingPriceController.text.trim()) ?? 0.0;
    widget.itemToUpdate.costPrice =
        double.tryParse(costPriceController.text.trim()) ?? 0.0;
    widget.itemToUpdate.orderDate = orderDateController.text.trim();
    widget.itemToUpdate.minStockLevel =
        int.tryParse(minStockController.text.trim()) ?? 0;
    widget.itemToUpdate.category = selectedCategory;
    widget.itemToUpdate.supplier = selectedSupplier;
    widget.itemToUpdate.carModel = selectedCarModel;

    bool success = await Provider.of<InventoryProvider>(
      context,
      listen: false,
    ).updateInventory(widget.itemToUpdate);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Update failed')));
    }

    setState(() => isLoading = false);
  }

  Future<void> onConfirmDelete() async {
    setState(() => isLoading = true);

    bool success = await Provider.of<InventoryProvider>(
      context,
      listen: false,
    ).deleteInventory(widget.itemToUpdate);

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Delete failed')));
    }

    setState(() {
      isLoading = false;
      showDeleteConfirmation = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Inventory")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: "Item Name",
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Part Category',
                        ),
                        value:
                            selectedCategory.isEmpty ? null : selectedCategory,
                        items:
                            categorySupplierMap.keys.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            selectedSupplier = categorySupplierMap[value]!;
                          });
                        },
                      ),
                      TextFormField(
                        controller: TextEditingController(
                          text: selectedSupplier,
                        ),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Supplier',
                        ),
                      ),
                      TextField(
                        controller: partNumberController,
                        decoration: const InputDecoration(
                          labelText: "Part Number / SKU",
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Car Model',
                        ),
                        value:
                            selectedCarModel.isEmpty ? null : selectedCarModel,
                        items:
                            carModelCompatibilityMap.keys.map((String model) {
                              return DropdownMenuItem<String>(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCarModel = value!;
                            compatibilityInfo =
                                carModelCompatibilityMap[value]!;
                          });
                        },
                      ),
                      TextFormField(
                        controller: TextEditingController(
                          text: compatibilityInfo,
                        ),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Compatible With',
                        ),
                      ),
                      TextField(
                        controller: quantityController,
                        decoration: const InputDecoration(
                          labelText: "Quantity in Stock",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: sellingPriceController,
                        decoration: const InputDecoration(
                          labelText: "Selling Price (RM)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(
                          labelText: "Cost Price (RM)",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: orderDateController,
                        decoration: const InputDecoration(
                          labelText: "Order Date (YYYY-MM-DD)",
                        ),
                      ),
                      TextField(
                        controller: minStockController,
                        decoration: const InputDecoration(
                          labelText: "Minimum Stock Level",
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: onSave,
                        child: const Text("Save Changes"),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => showDeleteConfirmation = true);
                        },
                        child: const Text(
                          "Delete Item",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      if (showDeleteConfirmation)
                        AlertDialog(
                          title: const Text("Confirm Deletion"),
                          content: const Text(
                            "Are you sure you want to delete this item?",
                          ),
                          actions: [
                            TextButton(
                              onPressed:
                                  () => setState(
                                    () => showDeleteConfirmation = false,
                                  ),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: onConfirmDelete,
                              child: const Text("Confirm"),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
    );
  }
}
