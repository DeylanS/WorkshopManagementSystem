import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String docId;
  String name;
  String email;
  String phoneNo;
  String role;
  String? address;
  String? companyName;
  double? paymentRate;
  double? latitude; // New
  double? longitude; // New
  final DateTime createdAt;
  DateTime updatedAt;
  int? inventory_count; // New field for inventory count
  String? workshopId; // New field for Schedule

  UserModel({
    required this.docId,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.role,
    this.address,
    this.companyName,
    this.paymentRate,
    this.latitude, // New
    this.longitude, // New
    required this.createdAt,
    required this.updatedAt,
    this.inventory_count, // Initialize inventory count
    this.workshopId, //New Constructor
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String docId) {
    return UserModel(
      docId: docId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phone_no'] ?? '',
      role: map['role'] ?? 'owner',
      address: map['address'],
      companyName: map['company_name'],
      paymentRate:
          map['payment_rate'] != null
              ? (map['payment_rate'] is int
                  ? (map['payment_rate'] as int).toDouble()
                  : map['payment_rate'] as double)
              : null,
      createdAt:
          map['created_at'] != null
              ? (map['created_at'] as Timestamp).toDate()
              : DateTime.now(), // fallback if missing
      updatedAt:
          map['updated_at'] != null
              ? (map['updated_at'] as Timestamp).toDate()
              : DateTime.now(),
      inventory_count:
          map['inventory_count'] ?? 0, // Initialize inventory count
      latitude:
          map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude:
          map['longitude'] != null
              ? (map['longitude'] as num).toDouble()
              : null,
      workshopId: map['workshop_id'], // extract from Firestore
    );
  }

  Map<String, dynamic> toMap() {
    final data = {
      'docId': docId,
      'name': name,
      'email': email,
      'phone_no': phoneNo,
      'role': role,
      'updated_at': FieldValue.serverTimestamp(),
      'latitude': latitude,
      'longitude': longitude,
    };

    if (role == 'owner') {
      data['address'] = address ?? '';
      data['inventory_count'] = inventory_count ?? 0;
      data['company_name'] = companyName ?? '';
      data.remove('payment_rate');
      data.remove('workshop_id');
    } else if (role == 'foreman') {
      data['payment_rate'] = paymentRate ?? 0.0;
      data['workshop_id'] = workshopId ?? '';
      data.remove('address');
      data.remove('inventory_count');
      data.remove('company_name');
    }

    return data;
  }
}

class UserService {
  final _users = FirebaseFirestore.instance.collection('users');

  Future<String?> getCurrentDocIdByEmail(String email) async {
    final snapshot = await _users.where('email', isEqualTo: email).get();
    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.id;
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final snapshot = await _users.where('email', isEqualTo: email).get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return UserModel.fromMap(doc.data(), doc.id);
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.docId).update(user.toMap());
  }

  Future<void> deleteUser(String docId) async {
    await _users.doc(docId).delete();
  }
}
