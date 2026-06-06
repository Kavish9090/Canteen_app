import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import 'student_home_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      StudentHomeScreen(onViewCart: () {
        setState(() {
          _currentIndex = 1;
        });
      }),
      const CartScreen(),
      const OrdersScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) {
                return Badge(
                  label: Text(cart.totalQuantity.toString()),
                  isLabelVisible: cart.totalQuantity > 0,
                  child: const Icon(Icons.shopping_cart_rounded),
                );
              },
            ),
            label: "Cart",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: "Orders",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
