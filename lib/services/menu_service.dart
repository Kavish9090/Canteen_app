import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of menu items for live updates
  Stream<List<MenuItemModel>> getMenuItemsStream() {
    return _firestore
        .collection('menu_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Toggle availability (Kitchen staff)
  Future<void> toggleAvailability(String itemId, bool isAvailable) async {
    await _firestore.collection('menu_items').doc(itemId).update({
      'isAvailable': isAvailable,
    });
  }

  // Update menu item
  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestore.collection('menu_items').doc(item.id).update(item.toMap());
  }
}