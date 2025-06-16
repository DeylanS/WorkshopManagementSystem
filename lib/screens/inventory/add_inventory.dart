import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../models/inventory.dart';
import '../../providers/inventory_provider.dart';
import '../../data/sample_data.dart';
import 'view_inventory.dart';
import 'inventory_dashboard.dart';

class AddInventoryPage extends StatefulWidget {
  const AddInventoryPage({super.key});

  @override
  State<AddInventoryPage> createState() => _AddInventoryPageState();
}

class _AddInventoryPageState extends State<AddInventoryPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController partNumberController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController sellingPriceController = TextEditingController();
  final TextEditingController costPriceController = TextEditingController();
  final TextEditingController orderDateController = TextEditingController();
  final TextEditingController minStockController = TextEditingController();

  String selectedCategory = '';
  String selectedSupplier = '';
  String selectedCarModel = '';
  String compatibilityInfo = '';
  File? selectedImage;

  bool isLoading = false;

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("No image selected")));
    }
  }

  Future<void> onSubmit() async {
    setState(() {
      isLoading = true;
    });

    String name = nameController.text.trim();
    String partNumber = partNumberController.text.trim();
    int quantity = int.tryParse(quantityController.text.trim()) ?? 0;
    double sellingPrice =
        double.tryParse(sellingPriceController.text.trim()) ?? 0.0;
    double costPrice = double.tryParse(costPriceController.text.trim()) ?? 0.0;
    String orderDate = orderDateController.text.trim();
    int minStock = int.tryParse(minStockController.text.trim()) ?? 0;

    if (name.isNotEmpty &&
        quantity > 0 &&
        selectedCategory.isNotEmpty &&
        selectedCarModel.isNotEmpty) {
      Inventory itemToAdd = Inventory(
        name: name,
        category: selectedCategory,
        partNumber: partNumber,
        carModel: selectedCarModel,
        quantity: quantity,
        price: sellingPrice,
        costPrice: costPrice,
        supplier: selectedSupplier,
        orderDate: orderDate,
        minStockLevel: minStock,
        imagePath:
            selectedImage
                ?.path, // Save local path (can change to URL if using Firebase)
      );

      bool success = await Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).addInventory(itemToAdd);

      if (success) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add inventory')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields with valid data'),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  void onClear() {
    nameController.clear();
    partNumberController.clear();
    quantityController.clear();
    sellingPriceController.clear();
    costPriceController.clear();
    orderDateController.clear();
    minStockController.clear();
    setState(() {
      selectedCategory = '';
      selectedSupplier = '';
      selectedCarModel = '';
      compatibilityInfo = '';
      selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Inventory"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ViewInventoryPage()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const InventoryDashboard()),
              );
            },
          ),
        ],
      ),
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
                        decoration: const InputDecoration(
                          labelText: 'Supplier',
                        ),
                        controller: TextEditingController(
                          text: selectedSupplier,
                        ),
                        readOnly: true,
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
                        decoration: const InputDecoration(
                          labelText: 'Compatible With',
                        ),
                        controller: TextEditingController(
                          text: compatibilityInfo,
                        ),
                        readOnly: true,
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
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text("Choose Part Image"),
                      ),
                      if (selectedImage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Image.file(selectedImage!, height: 150),
                        ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text("Submit"),
                      ),
                      TextButton(
                        onPressed: onClear,
                        child: const Text("Clear"),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
