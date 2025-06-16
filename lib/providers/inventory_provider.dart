import 'package:flutter/material.dart';
import '../models/inventory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Inventory> _inventoryList = [];

  List<Inventory> get inventoryList => List.unmodifiable(_inventoryList);

  InventoryProvider() {
    loadInventoryFromFirestore();
  }

  Future<void> loadInventoryFromFirestore() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('inventory').get();
      _inventoryList.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _inventoryList.add(Inventory.fromMap(doc.id, data));
      }
      notifyListeners();
    } catch (e) {
      print('Error loading inventory: $e');
    }
  }

  Future<bool> addInventory(Inventory item) async {
    try {
      DocumentReference docRef = await _firestore
          .collection('inventory')
          .add(item.toMap());
      _inventoryList.add(item.copyWith(id: docRef.id));
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding inventory: $e');
      return false;
    }
  }

  Future<bool> updateInventory(Inventory updatedItem) async {
    try {
      if (updatedItem.id == null) return false;
      await _firestore
          .collection('inventory')
          .doc(updatedItem.id)
          .update(updatedItem.toMap());

      int index = _inventoryList.indexWhere(
        (item) => item.id == updatedItem.id,
      );
      if (index != -1) {
        _inventoryList[index] = updatedItem;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error updating inventory: $e');
      return false;
    }
  }

  Future<bool> deleteInventory(Inventory item) async {
    try {
      if (item.id == null) return false;
      await _firestore.collection('inventory').doc(item.id).delete();
      _inventoryList.removeWhere((inv) => inv.id == item.id);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting inventory: $e');
      return false;
    }
  }
}
