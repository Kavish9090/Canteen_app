import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of menu items
  Stream<List<MenuItemModel>> getMenuItems() {
    return _firestore
        .collection('menu_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItemModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Add a new menu item
  Future<void> addMenuItem(MenuItemModel item) async {
    await _firestore.collection('menu_items').add(item.toMap());
  }

  // Update a menu item
  Future<void> updateMenuItem(MenuItemModel item) async {
    await _firestore.collection('menu_items').doc(item.id).update(item.toMap());
  }

  // Delete a menu item
  Future<void> deleteMenuItem(String id) async {
    await _firestore.collection('menu_items').doc(id).delete();
  }

  // Place a new order with a token number
  Future<OrderModel> placeOrder(OrderModel order) async {
    final today = DateTime.now();
    final dateStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final counterRef = _firestore.collection('token_counters').doc(dateStr);

    return _firestore.runTransaction((transaction) async {
      // 1. Get the current token count for today
      DocumentSnapshot counterSnapshot = await transaction.get(counterRef);
      
      int nextToken = 1;
      if (counterSnapshot.exists) {
        nextToken = (counterSnapshot.data() as Map<String, dynamic>)['lastToken'] + 1;
      }
      
      // 2. Update the counter
      transaction.set(counterRef, {'lastToken': nextToken});
      
      // 3. Create the order reference
      DocumentReference orderRef = _firestore.collection('orders').doc();
      
      // 4. Create a final order object with the token
      final finalOrder = OrderModel(
        id: orderRef.id,
        userId: order.userId,
        userName: order.userName,
        items: order.items,
        totalPrice: order.totalPrice,
        status: order.status,
        preparationTime: order.preparationTime,
        tokenNumber: nextToken,
        paymentId: order.paymentId,
        createdAt: order.createdAt,
        updatedAt: order.updatedAt,
      );
      
      // 5. Save the order
      transaction.set(orderRef, finalOrder.toMap());
      
      return finalOrder;
    });
  }

  // Record a payment record for audit
  Future<void> recordPayment({
    required String paymentId,
    required double amount,
    required String method,
    required String status,
    required String userId,
    String? orderId,
  }) async {
    await _firestore.collection('payments').add({
      'paymentId': paymentId,
      'amount': amount,
      'method': method,
      'status': status,
      'userId': userId,
      'orderId': orderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Stream orders for a specific student (ordered by createdAt descending)
  Stream<List<OrderModel>> getStudentOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      // Sort in-memory if Firestore compound indexes aren't created yet
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Stream all orders for admin
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      List<OrderModel> orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Seed default menu items if the database is empty
  Future<void> seedDefaultMenuIfNeeded() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('menu_items').limit(1).get();
      if (snapshot.docs.isEmpty) {
        List<MenuItemModel> defaultItems = [
          MenuItemModel(
            id: '',
            name: 'Chicken Biryani',
            price: 180.0,
            preparationTime: 20,
            category: 'Meals',
            imageUrl: 'https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Paneer Butter Masala & Naan',
            price: 150.0,
            preparationTime: 15,
            category: 'Meals',
            imageUrl: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Masala Dosa',
            price: 80.0,
            preparationTime: 10,
            category: 'Snacks',
            imageUrl: 'https://images.unsplash.com/photo-1668236543090-82eba5ee5976?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Veg Cheese Burger',
            price: 90.0,
            preparationTime: 12,
            category: 'Snacks',
            imageUrl: 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Cold Coffee with Ice Cream',
            price: 70.0,
            preparationTime: 5,
            category: 'Drinks',
            imageUrl: 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Mango Lassi',
            price: 60.0,
            preparationTime: 5,
            category: 'Drinks',
            imageUrl: 'https://images.unsplash.com/photo-1546173159-315724a31696?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Samosa (2 pcs)',
            price: 30.0,
            preparationTime: 5,
            category: 'Snacks',
            imageUrl: 'https://images.unsplash.com/photo-1601050690597-df056fb4ce78?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
          MenuItemModel(
            id: '',
            name: 'Chocolate Lava Brownie',
            price: 120.0,
            preparationTime: 8,
            category: 'Desserts',
            imageUrl: 'https://images.unsplash.com/photo-1606313564200-e75d5e30476c?q=80&w=600&auto=format&fit=crop',
            isAvailable: true,
          ),
        ];

        for (var item in defaultItems) {
          await addMenuItem(item);
        }
      }
    } catch (e) {
      print("Error seeding default menu: $e");
    }
  }
}
