import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/menu_item_model.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';

class AdminMenuScreen extends StatelessWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Manager", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: StreamBuilder<List<MenuItemModel>>(
        stream: DatabaseService().getMenuItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items in the menu. Click '+' to add."));
          }

          final menuItems = snapshot.data!;

          return ListView.builder(
            itemCount: menuItems.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final item = menuItems[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(width: 60, height: 60, color: Colors.grey.shade300, child: const Icon(Icons.fastfood)),
                    ),
                  ),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("₹${item.price.toStringAsFixed(1)} • ${item.category}"),
                      Text("Time: ${item.preparationTime} min"),
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: item.isAvailable,
                            onChanged: (val) {
                              final updated = MenuItemModel(
                                id: item.id,
                                name: item.name,
                                price: item.price,
                                preparationTime: item.preparationTime,
                                category: item.category,
                                imageUrl: item.imageUrl,
                                isAvailable: val,
                              );
                              DatabaseService().updateMenuItem(updated);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, color: Colors.black),
                            onPressed: () => _showAddEditItemDialog(context, item: item),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.black),
                            onPressed: () => _deleteItem(context, item.id, item.name),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditItemDialog(context),
        label: const Text("New Item"),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddEditItemDialog(BuildContext context, {MenuItemModel? item}) {
    final isEditing = item != null;

    final nameController = TextEditingController(text: item?.name ?? '');
    final priceController = TextEditingController(text: item?.price.toString() ?? '');
    final timeController = TextEditingController(text: item?.preparationTime.toString() ?? '');
    
    String selectedCategory = item?.category ?? 'Snacks';
    final categories = ['Meals', 'Snacks', 'Drinks', 'Desserts'];

    dynamic selectedImage; // File on mobile, Uint8List on web
    String? currentImageUrl = item?.imageUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            bool isLoading = false;

            return AlertDialog(
              title: Text(isEditing ? "Edit Menu Item" : "Add Menu Item", style: const TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image Picker Section
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );
                        
                        if (image != null) {
                          if (kIsWeb) {
                            final bytes = await image.readAsBytes();
                            setDialogState(() => selectedImage = bytes);
                          } else {
                            setDialogState(() => selectedImage = File(image.path));
                          }
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(selectedImage as Uint8List, fit: BoxFit.cover)
                                    : Image.file(selectedImage as File, fit: BoxFit.cover),
                              )
                            : (currentImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(currentImageUrl, fit: BoxFit.cover),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
                                      SizedBox(height: 8),
                                      Text("Pick Food Image", style: TextStyle(color: Colors.grey)),
                                    ],
                                  )),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Food Name", border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(labelText: "Price (₹)", border: OutlineInputBorder()),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: timeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: "Time (min)", border: OutlineInputBorder()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(labelText: "Category", border: OutlineInputBorder()),
                      items: categories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (nameController.text.trim().isEmpty ||
                        priceController.text.trim().isEmpty ||
                        timeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please fill all mandatory fields.")),
                      );
                      return;
                    }

                    setDialogState(() => isLoading = true);

                    try {
                      String imageUrl = currentImageUrl ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=600&auto=format&fit=crop';
                      
                      // Upload image if a new one is selected
                      if (selectedImage != null) {
                        imageUrl = await StorageService().uploadMenuItemImage(selectedImage);
                      }

                      final name = nameController.text.trim();
                      final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                      final prepTime = int.tryParse(timeController.text.trim()) ?? 10;

                      final newItem = MenuItemModel(
                        id: isEditing ? item.id : '',
                        name: name,
                        price: price,
                        preparationTime: prepTime,
                        category: selectedCategory,
                        imageUrl: imageUrl,
                        isAvailable: isEditing ? item.isAvailable : true,
                      );

                      if (isEditing) {
                        await DatabaseService().updateMenuItem(newItem);
                      } else {
                        await DatabaseService().addMenuItem(newItem);
                      }
                      
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      setDialogState(() => isLoading = false);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    }
                  },
                  child: isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(isEditing ? "Save" : "Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteItem(BuildContext context, String itemId, String itemName) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete Item?"),
            content: Text("Are you sure you want to delete '$itemName'? This item will be permanently removed from the menu."),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.black))),
            ],
          ),
        ) ??
        false;

    if (!confirm) return;

    try {
      await DatabaseService().deleteMenuItem(itemId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Menu item deleted."), backgroundColor: Colors.black, duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }
}
