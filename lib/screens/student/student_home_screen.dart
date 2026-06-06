import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';

class StudentHomeScreen extends StatefulWidget {
  final VoidCallback? onViewCart;

  const StudentHomeScreen({super.key, this.onViewCart});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = ['All', 'Meals', 'Snacks', 'Drinks', 'Desserts'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'meals':
        return Colors.blue;
      case 'snacks':
        return Colors.orange;
      case 'drinks':
        return Colors.green;
      case 'desserts':
        return Colors.pink;
      default:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final userName = userProvider.user?.name ?? 'Guest';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar / Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome,",
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.6),
                              ),
                            ),
                            Text(
                              userName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      decoration: InputDecoration(
                        hintText: "Search delicious food...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Category Selection
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final category = _categories[index];
                          final isSelected = _selectedCategory == category;
                          
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedCategory = category;
                                  });
                                }
                              },
                              selectedColor: theme.colorScheme.primary,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? Colors.transparent : Colors.deepOrange.withOpacity(0.2),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Popular Items",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Menu Items List from Firestore
            StreamBuilder<List<MenuItemModel>>(
              stream: DatabaseService().getMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No items available in the menu.")),
                  );
                }

                // Filter items based on category and search query
                final filteredItems = snapshot.data!.where((item) {
                  final matchesCategory = _selectedCategory == 'All' ||
                      item.category.toLowerCase() == _selectedCategory.toLowerCase();
                  final matchesSearch = item.name.toLowerCase().contains(_searchQuery);
                  return matchesCategory && matchesSearch && item.isAvailable;
                }).toList();

                if (filteredItems.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: Text("No items match your search.")),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = filteredItems[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // Food Image
                            Image.network(
                              item.imageUrl,
                              width: 110,
                              height: 110,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 110,
                                  height: 110,
                                  color: theme.colorScheme.surfaceVariant,
                                  child: const Icon(Icons.fastfood, size: 40),
                                );
                              },
                            ),
                            
                            // Food details
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getCategoryColor(item.category).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: _getCategoryColor(item.category).withOpacity(0.3)),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: _getCategoryColor(item.category),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.timer_outlined, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${item.preparationTime}m",
                                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "₹${item.price.toStringAsFixed(1)}",
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            cartProvider.addItem(item);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text("${item.name} added to cart!"),
                                                duration: const Duration(seconds: 1),
                                                action: SnackBarAction(
                                                  label: "VIEW CART",
                                                  onPressed: widget.onViewCart ?? () {},
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                            backgroundColor: theme.colorScheme.primary,
                                            foregroundColor: theme.colorScheme.onPrimary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text("Add", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    childCount: filteredItems.length,
                  ),
                );
              },
            ),
            
            // Padding at bottom
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
}
