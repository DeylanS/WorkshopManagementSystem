import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/user_service.dart' as service;
import '../screens/auth/signup_page.dart';
import '../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  final service.UserService _service = service.UserService();

  UserModel? _user;
  bool _isUserLoaded = false;

  UserModel? get user => _user;
  bool get isUserLoaded => _isUserLoaded;
  String get currentUserRole => _user?.role ?? '';
  String? get workshopId => _user?.workshopId;

  List<UserModel> _users = [];
  List<UserModel> get users => _users;
  List<UserModel> get foremen =>
      _users.where((u) => u.role == 'foreman').toList();

  // Load logged-in user data
  Future<void> loadUser() async {
    final email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) {
      print("No logged-in user email found.");
      return;
    }

    try {
      final fetchedUser = await _service.getUserByEmail(email);
      if (fetchedUser == null) {
        print("UserService.getUserByEmail returned null for email: $email");
        _user = null;
      } else {
        _user = fetchedUser;
      }
      _isUserLoaded = true;
      notifyListeners();
    } catch (e, stack) {
      print("Error loading user: $e\n$stack");
      _user = null;
      _isUserLoaded = false;
      notifyListeners();
    }
  }

  // Update current user data
  Future<void> updateUser(
    String name,
    String email,
    String phoneNo,
    String role, {
    String? address,
    String? companyName,
    double? paymentRate,
    double? latitude,
    double? longitude,
    String? workshopId,
  }) async {
    if (_user == null) {
      print("No user loaded to update.");
      return;
    }

    _user!
      ..name = name
      ..email = email
      ..phoneNo = phoneNo
      ..role = role
      ..updatedAt = DateTime.now();

    if (role == 'owner') {
      _user!
        ..address = address ?? ''
        ..companyName = companyName ?? ''
        ..paymentRate = null
        ..latitude = latitude
        ..longitude = longitude
        ..workshopId = null;
    } else if (role == 'foreman') {
      _user!
        ..address = null
        ..companyName = null
        ..latitude = null
        ..longitude = null
        ..paymentRate = paymentRate ?? 0.0
        ..workshopId = workshopId ?? '';
    }

    try {
      await _service.updateUser(_user!);
      notifyListeners();
    } catch (e, stack) {
      print("Error updating user: $e\n$stack");
    }
  }

  // Delete the current user (auth + firestore)
  Future<void> deleteUser(BuildContext context) async {
    if (_user == null) {
      print("No user loaded to delete.");
      return;
    }

    final confirm = await _showDeleteConfirmation(context);
    if (!confirm) return;

    try {
      final authUser = FirebaseAuth.instance.currentUser;
      if (authUser != null) {
        await authUser.delete();
      }

      await _service.deleteUser(_user!.docId);

      _user = null;
      _isUserLoaded = false;
      notifyListeners();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SignUpPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully.')),
      );
    } catch (e, stack) {
      print("Error deleting user: $e\n$stack");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting user: $e')));
    }
  }

  // Confirmation dialog for deletion
  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (_) => AlertDialog(
                title: const Text('Delete Account'),
                content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Fetch all users (for admin use)
  Future<void> fetchAllUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      _users =
          snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList();
      notifyListeners();
    } catch (e, stack) {
      print("Error fetching users: $e\n$stack");
    }
  }

  // Assign a foreman to a workshop (owner docId)
  Future<void> assignForemanToWorkshop(
    String foremanDocId,
    String ownerDocId,
  ) async {
    try {
      UserModel? foreman;
      try {
        foreman = _users.firstWhere(
          (u) => u.docId == foremanDocId && u.role == 'foreman',
        );
      } catch (_) {
        foreman = null;
      }

      if (foreman == null) {
        print("Foreman not found.");
        return;
      }

      foreman.workshopId = ownerDocId;

      await _service.updateUser(foreman);
      await fetchAllUsers();
      notifyListeners();

      print("Foreman assigned to workshop.");
    } catch (e, stack) {
      print("Error assigning foreman: $e\n$stack");
    }
  }
}
