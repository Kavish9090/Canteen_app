import 'package:cloud_firestore/cloud_firestore.dart';

class OrderCartItem {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  
  OrderCartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory OrderCartItem.fromMap(Map<String, dynamic> map) {
    return OrderCartItem(
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<OrderCartItem> items;
  final double totalPrice;
  final String status; // 'Pending', 'Preparing', 'Ready', 'Completed', 'Cancelled'
  final int preparationTime;
  final int? tokenNumber;
  final String? paymentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalPrice,
    required this.status,
    required this.preparationTime,
    this.tokenNumber,
    this.paymentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    List<OrderCartItem> parsedItems = [];
    if (map['items'] is List) {
      for (var item in (map['items'] as List)) {
        try {
          if (item is Map) {
            parsedItems.add(OrderCartItem.fromMap(Map<String, dynamic>.from(item)));
          }
        } catch (e) {
          print("Skipping corrupt order item: $e");
        }
      }
    }

    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      items: parsedItems,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'Pending',
      preparationTime: map['preparationTime'] ?? 10,
      tokenNumber: map['tokenNumber'],
      paymentId: map['paymentId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalPrice': totalPrice,
      'status': status,
      'preparationTime': preparationTime,
      'tokenNumber': tokenNumber,
      'paymentId': paymentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
