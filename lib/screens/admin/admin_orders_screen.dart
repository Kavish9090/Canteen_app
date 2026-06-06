import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';
import 'package:intl/intl.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Order Queue", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "New"),
              Tab(text: "Preparing"),
              Tab(text: "Ready"),
            ],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: DatabaseService().getAllOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No orders found."));
            }

            final orders = snapshot.data!;
            
            final pendingOrders = orders.where((o) => o.status == 'Pending').toList();
            final preparingOrders = orders.where((o) => o.status == 'Preparing').toList();
            final readyOrders = orders.where((o) => o.status == 'Ready').toList();

            return TabBarView(
              children: [
                _buildOrderList(context, pendingOrders, "No new orders.", 'Pending'),
                _buildOrderList(context, preparingOrders, "Nothing being prepared.", 'Preparing'),
                _buildOrderList(context, readyOrders, "No orders ready for pickup.", 'Ready'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, List<OrderModel> orders, String emptyMessage, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(emptyMessage, style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: orders.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderCard(order: order);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr = DateFormat('jm').format(order.createdAt);
    final elapsed = DateTime.now().difference(order.createdAt).inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "TOKEN: ${order.tokenNumber ?? 'N/A'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      timeStr,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                if (order.status != 'Completed' && order.status != 'Cancelled')
                  Text(
                    "$elapsed min ago",
                    style: TextStyle(
                      color: elapsed > 15 ? Colors.black : Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Text(
              order.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            
            // List Items
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "x${item.quantity}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(item.name, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                )),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (order.status == 'Pending' || order.status == 'Preparing')
                  TextButton(
                    onPressed: () => _updateStatus(context, order.id, 'Cancelled'),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                const SizedBox(width: 8),
                _buildActionButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    switch (order.status) {
      case 'Pending':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, order.id, 'Preparing'),
          icon: const Icon(Icons.hourglass_empty_rounded),
          label: const Text("Accept Order"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade50,
            foregroundColor: Colors.orange.shade900,
            side: BorderSide(color: Colors.orange.withOpacity(0.3)),
          ),
        );
      case 'Preparing':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, order.id, 'Ready'),
          icon: const Icon(Icons.dining_rounded),
          label: const Text("Mark Ready"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade50,
            foregroundColor: Colors.blue.shade900,
            side: BorderSide(color: Colors.blue.withOpacity(0.3)),
          ),
        );
      case 'Ready':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus(context, order.id, 'Completed'),
          icon: const Icon(Icons.check_circle_rounded),
          label: const Text("Collected"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _updateStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await DatabaseService().updateOrderStatus(orderId, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Order marked as $newStatus"),
            backgroundColor: _getStatusColor(newStatus),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.black),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Preparing': return Colors.blue;
      case 'Ready': return Colors.green;
      case 'Completed': return Colors.teal;
      case 'Cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}
