import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';

class OrderSuccessScreen extends StatelessWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Icon Animation placeholder
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.black,
                  size: 80,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Order Confirmed!",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Your order has been placed successfully.",
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Token Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    Text(
                      "YOUR TOKEN NUMBER",
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      order.tokenNumber.toString(),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Order Details Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _detailRow("Estimated Time", "${order.preparationTime} mins"),
                    const Divider(height: 24),
                    _detailRow("Total Amount", "₹${order.totalPrice.toStringAsFixed(1)}"),
                    const Divider(height: 24),
                    _detailRow("Items", "${order.items.length} items"),
                  ],
                ),
              ),
              const Spacer(),

              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderDetailScreen(orderId: order.id),
                  ),
                ),
                child: const Text("View Order Details"),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
