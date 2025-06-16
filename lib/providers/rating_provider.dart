import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating.dart';

class RatingProvider with ChangeNotifier {
  // All ratings (for admin or manager view)
  List<Rating> _ratings = [];
  List<Rating> get ratings => _ratings;

  // Current user's ratings
  List<Rating> _userRating = [];
  List<Rating> get userRating => _userRating;

  /// Fetch all ratings
  Future<void> fetchRatings() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('ratings').get();
      _ratings =
          snapshot.docs
              .map((doc) => Rating.fromMap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching all ratings: $e');
    }
  }

  /// Fetch only ratings by current user
  Future<void> fetchUserRating() async {
    try {
      final currentUserId = 'owner123'; // TODO: Replace with real auth user ID

      final snapshot =
          await FirebaseFirestore.instance
              .collection('ratings')
              .where('ownerID', isEqualTo: currentUserId)
              .get();

      _userRating =
          snapshot.docs
              .map((doc) => Rating.fromMap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e) {
      print('Error fetching user ratings: $e');
    }
  }

  /// Add a new rating
  Future<void> addRating(Rating rating) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('ratings')
          .add(rating.toMap());

      final newRating = Rating.fromMap(rating.toMap(), docRef.id);
      _ratings.add(newRating);
      _userRating.add(newRating);
      notifyListeners();
    } catch (e) {
      print('Error adding rating: $e');
    }
  }

  /// Delete a rating by ID
  Future<void> deleteRating(String id) async {
    try {
      await FirebaseFirestore.instance.collection('ratings').doc(id).delete();
      _ratings.removeWhere((r) => r.ratingId == id);
      _userRating.removeWhere((r) => r.ratingId == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting rating: $e');
    }
  }
}
