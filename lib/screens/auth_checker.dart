import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';
import 'student/student_main_screen.dart';
import 'admin/admin_main_screen.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  StreamSubscription<User?>? _authSubscription;
  bool _isLoading = true;
  User? _firebaseUser;

  @override
  void initState() {
    super.initState();
    // Initialize notification service after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService().initialize(context);
    });

    // Listen to auth state changes imperatively
    _authSubscription = AuthService().authStateChanges.listen((user) async {
      if (!mounted) return;
      
      if (user != null) {
        // Fetch user profile
        await Provider.of<UserProvider>(context, listen: false).fetchUser(user.uid);
      } else {
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }

      if (mounted) {
        setState(() {
          _firebaseUser = user;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_firebaseUser == null) {
      return const LoginScreen();
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final profile = userProvider.user;

        if (profile == null) {
          // Signed in with Firebase but no Firestore profile — sign out
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AuthService().signOut();
          });
          return const LoginScreen();
        }

        final role = profile.role.toLowerCase().trim();
        if (role == 'staff' || role == 'admin') {
          return const AdminMainScreen();
        } else {
          return const StudentMainScreen();
        }
      },
    );
  }
}