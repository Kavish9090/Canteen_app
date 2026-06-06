import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/order_model.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Tracking", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Order not found or was deleted."));
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final order = OrderModel.fromMap(orderData, snapshot.data!.id);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top success header
                Card(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Order #${order.id.substring(0, 8).toUpperCase()}",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Estimated Prep Time: ${order.preparationTime} minutes",
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Real-time tracking Stepper
                Text(
                  "Order Status",
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTrackerTimeline(context, order.status),
                const SizedBox(height: 32),

                // Order items list
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Items Ordered",
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(height: 20),
                        ...order.items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
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
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Total Paid",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "₹${order.totalPrice.toStringAsFixed(1)}",
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTrackerTimeline(BuildContext context, String currentStatus) {
    int currentStep = 0;
    if (currentStatus == 'Pending') currentStep = 1;
    if (currentStatus == 'Preparing') currentStep = 2;
    if (currentStatus == 'Ready') currentStep = 3;
    if (currentStatus == 'Completed') currentStep = 4;
    if (currentStatus == 'Cancelled') currentStep = -1;

    return Column(
      children: [
        _buildTimelineStep(
          context,
          stepNumber: 1,
          title: "Order Placed",
          description: "Your order has been received by the canteen.",
          status: currentStep >= 1 ? (currentStep > 1 ? 'completed' : 'active') : 'inactive',
          isCancelled: currentStep == -1,
        ),
        _buildTimelineConnector(context, currentStep > 1, currentStep == -1),
        _buildTimelineStep(
          context,
          stepNumber: 2,
          title: "Preparing Food",
          description: "The kitchen is preparing your delicious meal.",
          status: currentStep >= 2 ? (currentStep > 2 ? 'completed' : 'active') : 'inactive',
          isCancelled: currentStep == -1,
        ),
        _buildTimelineConnector(context, currentStep > 2, currentStep == -1),
        _buildTimelineStep(
          context,
          stepNumber: 3,
          title: "Ready for Pickup",
          description: "Collect your freshly prepared food at the counter!",
          status: currentStep >= 3 ? (currentStep > 3 ? 'completed' : 'active') : 'inactive',
          isCancelled: currentStep == -1,
          glow: currentStep == 3,
        ),
        _buildTimelineConnector(context, currentStep > 3, currentStep == -1),
        _buildTimelineStep(
          context,
          stepNumber: 4,
          title: "Picked Up & Completed",
          description: "Enjoy your food! Have a wonderful day.",
          status: currentStep == 4 ? 'active' : (currentStep > 4 ? 'completed' : 'inactive'),
          isCancelled: currentStep == -1,
        ),
      ],
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required int stepNumber,
    required String title,
    required String description,
    required String status, // 'inactive', 'active', 'completed'
    required bool isCancelled,
    bool glow = false,
  }) {
    final theme = Theme.of(context);
    final isActive = status != 'inactive';
    final isCompleted = status == 'completed';

    Color stepColor = isCompleted
        ? Colors.grey.shade400
        : status == 'active'
            ? (isCancelled ? Colors.red : (stepNumber == 1 ? Colors.orange : stepNumber == 2 ? Colors.blue : stepNumber == 3 ? Colors.green : Colors.teal))
            : Colors.grey.shade300;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween<double>(begin: 0.8, end: 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: status == 'active' ? scale : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: stepColor,
                      shape: BoxShape.circle,
                      boxShadow: glow
                          ? [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.4),
                                blurRadius: 12,
                                spreadRadius: 4,
                              )
                            ]
                          : [],
                    ),
                    child: Center(
                      child: isCompleted
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : isCancelled
                              ? const Icon(Icons.close, color: Colors.white, size: 20)
                              : Text(
                                  stepNumber.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: theme.textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? theme.colorScheme.onBackground : Colors.grey.shade500,
                ),
                child: Text(title),
              ),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isActive ? 1.0 : 0.6,
                child: Text(
                  description,
                  style: TextStyle(
                    color: isActive ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector(BuildContext context, bool isCompleted, bool isCancelled) {
    return Container(
      margin: const EdgeInsets.only(left: 17, top: 4, bottom: 4),
      height: 30,
      width: 2,
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey.shade600 : (isCancelled ? Colors.grey.shade400 : Colors.grey.shade200),
      ),
    );
  }
}
