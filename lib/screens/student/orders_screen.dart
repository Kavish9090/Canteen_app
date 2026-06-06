import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active Orders"),
              Tab(text: "Order History"),
            ],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: DatabaseService().getStudentOrders(userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 80,
                      color: theme.colorScheme.onBackground.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No orders yet",
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              );
            }

            final orders = snapshot.data!;
            
            // Filter active orders vs history
            final activeStatuses = ['Pending', 'Preparing', 'Ready'];
            final activeOrders = orders.where((o) => activeStatuses.contains(o.status)).toList();
            final pastOrders = orders.where((o) => !activeStatuses.contains(o.status)).toList();

            return TabBarView(
              children: [
                _buildOrderList(context, activeOrders, "No active orders. Order something delicious!", true),
                _buildOrderList(context, pastOrders, "No order history found.", false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orderList, String emptyMessage, bool isActive) {
    final theme = Theme.of(context);
    
    if (orderList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: theme.colorScheme.onBackground.withOpacity(0.5)),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: orderList.length,
      itemBuilder: (context, index) {
        final order = orderList[index];
        final formattedDate = _formatDateTime(order.createdAt);
        final statusColor = _getStatusColor(order.status);

        return Card(
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailScreen(orderId: order.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Order #${order.id.substring(0, 5).toUpperCase()}",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor),
                        ),
                        child: Text(
                          order.status,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const Divider(height: 24),
                  
                  // List of items in this order
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${item.name} x ${item.quantity}",
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text("₹${(item.price * item.quantity).toStringAsFixed(1)}"),
                          ],
                        ),
                      )),
                  
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Price",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "₹${order.totalPrice.toStringAsFixed(1)}",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (isActive && order.status != 'Ready') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(
                          "Est. Preparation: ~${order.preparationTime} mins",
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Preparing':
        return Colors.blue;
      case 'Ready':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  String _formatDateTime(DateTime dt) {
    // Basic formatting helper
    return "${dt.day}/${dt.month}/${dt.year} at ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
