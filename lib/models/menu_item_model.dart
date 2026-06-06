import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItemModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final bool isAvailable;
  final String imageUrl;
  final int preparationTime;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.isAvailable,
    required this.imageUrl,
    required this.preparationTime,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> data, String documentId) {
    return MenuItemModel(
      id: documentId,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      isAvailable: data['isAvailable'] ?? true,
      imageUrl: data['imageUrl'] ?? '',
      preparationTime: data['preparationTime'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'isAvailable': isAvailable,
      'imageUrl': imageUrl,
      'preparationTime': preparationTime,
    };
  }
}
