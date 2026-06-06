import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../services/database_service.dart';
import '../../providers/cart_provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: DatabaseService().getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No Menu Items Available"),
            );
          }

          final items = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];

              return Opacity(
                opacity: item.isAvailable ? 1 : 0.6,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                              child: Image.network(
                                item.imageUrl,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                  color: theme.colorScheme.surfaceVariant,
                                  child: const Icon(Icons.fastfood, size: 40),
                                ),
                              ),
                            ),
                            if (!item.isAvailable)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Unavailable",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.category,
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "₹${item.price.toStringAsFixed(0)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                    fontSize: 16,
                                  ),
                                ),
                                if (item.isAvailable)
                                  InkWell(
                                    onTap: () {
                                      cartProvider.addItem(item);
                                      ScaffoldMessenger.of(context)
                                          .hideCurrentSnackBar();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text("${item.name} added!"),
                                          duration: const Duration(seconds: 1),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
