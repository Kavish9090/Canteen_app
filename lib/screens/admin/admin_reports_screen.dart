import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../services/database_service.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('EEE, MMM d, yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Reports", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Date Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Icon(Icons.calendar_month, color: theme.colorScheme.primary),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: DatabaseService().getAllOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const _NoDataView();
                }

                // Filter for selected date and Completed status
                final dayOrders = snapshot.data!.where((order) {
                  final orderDate = order.createdAt;
                  return orderDate.year == _selectedDate.year &&
                      orderDate.month == _selectedDate.month &&
                      orderDate.day == _selectedDate.day &&
                      order.status == 'Completed';
                }).toList();

                if (dayOrders.isEmpty) {
                  return const _NoDataView(message: "No sales recorded for this date.");
                }

                // Calculate Stats
                double totalRevenue = 0;
                Map<String, int> itemCounts = {};
                Map<int, int> hourlyStats = {};

                for (var order in dayOrders) {
                  totalRevenue += order.totalPrice;
                  
                  // Item-wise count
                  for (var item in order.items) {
                    itemCounts[item.name] = (itemCounts[item.name] ?? 0) + item.quantity;
                  }

                  // Hourly stats
                  final hour = order.createdAt.hour;
                  hourlyStats[hour] = (hourlyStats[hour] ?? 0) + 1;
                }

                final topItem = itemCounts.entries.isNotEmpty 
                    ? itemCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key 
                    : "N/A";

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Summary CardsRow
                      Row(
                        children: [
                          _buildStatCard(
                            context,
                            "Revenue",
                            "₹${totalRevenue.toStringAsFixed(1)}",
                            Icons.payments_outlined,
                            Colors.green,
                          ),
                          const SizedBox(width: 12),
                          _buildStatCard(
                            context,
                            "Orders",
                            dayOrders.length.toString(),
                            Icons.receipt_outlined,
                            Colors.blue,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildStatCard(
                        context,
                        "Popular Item",
                        topItem,
                        Icons.star_outline,
                        Colors.amber.shade700,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 24),
                      Text("Item-wise Breakdown", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: itemCounts.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final entry = itemCounts.entries.elementAt(index);
                            return ListTile(
                              title: Text(entry.key),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text("${entry.value} sold", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      Text("Hourly Traffic", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            height: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: List.generate(24, (index) {
                                final count = hourlyStats[index] ?? 0;
                                final maxCount = hourlyStats.values.isEmpty ? 1 : hourlyStats.values.reduce((a, b) => a > b ? a : b);
                                final barHeight = (count / maxCount) * 100;
                                
                                if (index < 8 || index > 20) return const SizedBox.shrink(); // Hide night hours

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: barHeight + 4,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary.withOpacity(count > 0 ? 0.8 : 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text("${index}h", style: const TextStyle(fontSize: 8, color: Colors.grey)),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, {bool fullWidth = false}) {
    final card = Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }
}

class _NoDataView extends StatelessWidget {
  final String message;
  const _NoDataView({this.message = "No reports available."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade400)),
        ],
      ),
    );
  }
}
