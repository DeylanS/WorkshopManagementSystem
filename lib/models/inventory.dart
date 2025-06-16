class Inventory {
  final String? id; // Firestore document ID
  String name;
  String category;
  String partNumber;
  String carModel;
  int quantity;
  double price; // Selling price
  double costPrice;
  String supplier;
  String? orderDate;
  int minStockLevel;
  String? imagePath; // Optional for future image support

  Inventory({
    this.id,
    required this.name,
    required this.category,
    required this.partNumber,
    required this.carModel,
    required this.quantity,
    required this.price,
    required this.costPrice,
    required this.supplier,
    this.orderDate,
    required this.minStockLevel,
    this.imagePath,
  });

  Inventory copyWith({
    String? id,
    String? name,
    String? category,
    String? partNumber,
    String? carModel,
    int? quantity,
    double? price,
    double? costPrice,
    String? supplier,
    String? orderDate,
    int? minStockLevel,
    String? imagePath,
  }) {
    return Inventory(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      partNumber: partNumber ?? this.partNumber,
      carModel: carModel ?? this.carModel,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      supplier: supplier ?? this.supplier,
      orderDate: orderDate ?? this.orderDate,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'partNumber': partNumber,
      'carModel': carModel,
      'quantity': quantity,
      'price': price,
      'costPrice': costPrice,
      'supplier': supplier,
      'orderDate': orderDate,
      'minStockLevel': minStockLevel,
      'imagePath': imagePath,
    };
  }

  factory Inventory.fromMap(String id, Map<String, dynamic> map) {
    return Inventory(
      id: id,
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      partNumber: map['partNumber'] ?? '',
      carModel: map['carModel'] ?? '',
      quantity: map['quantity'] ?? 0,
      price: (map['price'] ?? 0).toDouble(),
      costPrice: (map['costPrice'] ?? 0).toDouble(),
      supplier: map['supplier'] ?? '',
      orderDate: map['orderDate'],
      minStockLevel: map['minStockLevel'] ?? 0,
      imagePath: map['imagePath'],
    );
  }
}
