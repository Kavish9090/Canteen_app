import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item_model.dart';
import '../../models/order_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import 'order_detail_screen.dart';
import 'order_success_screen.dart';
import '../../services/payment_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../utils/app_config.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'Counter Cash'; // Default payment option
  bool _isOrdering = false;
  late PaymentService _paymentService;
  
  // Centralized key from AppConfig
  final String _razorpayKey = AppConfig.RAZORPAY_KEY; 

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentFailure,
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Phase 5.3: On payment success -> place order
    _placeFinalOrder(response.paymentId);
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    // Phase 5.4: Handle payment failure gracefully
    setState(() => _isOrdering = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.black,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _handlePlaceOrder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: cart.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.colorScheme.onBackground.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Your cart is empty",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Add delicious food from the home menu!",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final cartItem = cart.items.values.toList()[index];
                      final itemId = cart.items.keys.toList()[index];
                      
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: Row(
                            children: [
                              // Small item avatar/icon
                              CircleAvatar(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black,
                                child: const Icon(Icons.restaurant_outlined),
                              ),
                              const SizedBox(width: 16),
                              
                              // Item name and price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      cartItem.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${cartItem.price.toStringAsFixed(1)}",
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Quantity controls
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    color: theme.colorScheme.primary,
                                    onPressed: () {
                                      cart.decreaseQuantity(itemId);
                                    },
                                  ),
                                  Text(
                                    cartItem.quantity.toString(),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    color: theme.colorScheme.primary,
                                    onPressed: () {
                                      // Create a mock MenuItemModel to trigger add
                                      cart.addItem(
                                        cartItemToMenuItem(cartItem, cart.estimatedPrepTime),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Bottom Details Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Prep Time Estimation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Estimated Preparation:",
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            "~${cart.estimatedPrepTime} mins",
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Payment Method Selector
                      const Text(
                        "Choose Payment Method",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text("Counter Cash"),
                              selected: _paymentMethod == 'Counter Cash',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _paymentMethod = 'Counter Cash';
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text("Online Pay"),
                              selected: _paymentMethod == 'Online Pay',
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _paymentMethod = 'Online Pay';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Total pricing
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount:",
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "₹${cart.totalAmount.toStringAsFixed(1)}",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Place Order Button
                      ElevatedButton(
                        onPressed: _isOrdering ? null : _handlePlaceOrder,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isOrdering
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Place Order",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _handlePlaceOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    if (userProvider.user == null) return;

    setState(() {
      _isOrdering = true;
    });

    if (_paymentMethod == 'Online Pay') {
      // Start Razorpay Checkout
      _paymentService.openCheckout(
        apiKey: _razorpayKey,
        amount: cart.totalAmount,
        name: "Canteen App",
        description: "Payment for Order",
        email: userProvider.user!.email,
        contact: "9999999999", // Placeholder contact
      );
    } else {
      // Direct Cash checkout
      _placeFinalOrder('Cash');
    }
  }

  void _placeFinalOrder(String? paymentId) async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final newOrder = OrderModel(
      id: '', // Generated by Firestore
      userId: userProvider.user!.uid,
      userName: userProvider.user!.name,
      items: cart.items.values.toList(),
      totalPrice: cart.totalAmount,
      status: 'Pending',
      preparationTime: cart.estimatedPrepTime,
      paymentId: paymentId ?? 'Pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      // Phase 5.3: Place order after payment confirmed
      OrderModel confirmedOrder = await DatabaseService().placeOrder(newOrder);
      
      // Phase 5.5: Write payment record to Firestore
      if (paymentId != 'Cash' && paymentId != null) {
        await DatabaseService().recordPayment(
          paymentId: paymentId,
          amount: cart.totalAmount,
          method: 'Razorpay',
          status: 'success',
          userId: userProvider.user!.uid,
          orderId: confirmedOrder.id,
        );
      }

      cart.clearCart();
      
      // Phase 5.6: Show order confirmed screen
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => OrderSuccessScreen(order: confirmedOrder),
          ),
          (route) => route.isFirst,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to place order: $e"),
            backgroundColor: Colors.black,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isOrdering = false;
        });
      }
    }
  }
}

MenuItemModel cartItemToMenuItem(OrderCartItem item, int prepTime) {
  return MenuItemModel(
    id: item.productId,
    name: item.name,
    price: item.price,
    preparationTime: prepTime,
    category: '',
    imageUrl: '',
    isAvailable: true,
  );
}
