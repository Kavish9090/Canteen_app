import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    final name = user?.name ?? 'User';
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Card Header
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
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
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
                        "Student Portal",
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

            // Profile Options list
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.history_rounded, color: Colors.black),
                      title: const Text("Purchase History"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Navigates or instructs
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.payment_rounded, color: Colors.black),
                      title: const Text("Payment Methods"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Mock details
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined, color: Colors.black),
                      title: const Text("Settings"),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                      onTap: () {
                        // Settings panel
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () async {
                await AuthService().signOut();
                userProvider.clearUser();
                // Checker automatically redirects to LoginScreen
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
                  Text("Log Out", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
