import 'package:flutter/material.dart';
import '../models/schedule.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'schedules';

  List<Schedule> _schedules = [];

  List<Schedule> get schedules => List.unmodifiable(_schedules);

  /// Load schedules from Firebase
  Future<void> fetchSchedules() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();
      _schedules =
          snapshot.docs.map((doc) {
            return Schedule.fromMap(doc.data(), doc.id);
          }).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching schedules: $e');
    }
  }

  /// Add schedule to Firebase and local list
  Future<void> addSchedule(Schedule schedule) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(schedule.id)
          .set(schedule.toMap());
      _schedules.add(schedule);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding schedule: $e');
    }
  }

  /// Update a schedule in Firebase
  Future<void> updateSchedule(String id, Schedule updatedSchedule) async {
    try {
      final index = _schedules.indexWhere((s) => s.id == id);
      if (index != -1) {
        await _firestore
            .collection(_collectionName)
            .doc(id)
            .update(updatedSchedule.toMap());
        _schedules[index] = updatedSchedule;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating schedule: $e');
    }
  }

  /// Delete schedule from Firebase and local list
  Future<void> deleteSchedule(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      _schedules.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting schedule: $e');
    }
  }

  /// Get a schedule by ID
  Schedule? getById(String id) {
    try {
      return _schedules.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
}
