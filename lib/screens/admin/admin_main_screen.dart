import 'package:flutter/material.dart';
import 'admin_orders_screen.dart';
import 'admin_menu_screen.dart';
import 'admin_reports_screen.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import 'package:provider/provider.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminOrdersScreen(),
    const AdminMenuScreen(),
    const AdminReportsScreen(),
    const AdminProfileTab(),
  ];

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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: "Menu",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: "Reports",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final name = user?.name ?? 'Staff';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Dashboard", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'A',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Role: ${user?.role ?? 'Unknown'}",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Staff stats card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Kitchen Guidelines", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text("Accept new orders promptly in the Orders tab.")),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text("Mark orders as Ready when prepared for pickup.")),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.black, size: 20),
                        SizedBox(width: 8),
                        Expanded(child: Text("Manage prices and availability under Menu Editor.")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            
            // Logout
            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                userProvider.clearUser();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded),
                  SizedBox(width: 8),
                  Text("Log Out Staff", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
