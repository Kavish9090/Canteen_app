import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.fastfood_rounded,
                  size: 100,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Canteen Ease",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Smart Food Ordering & Management",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 40),

                // Email
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email";
                    }
                    if (!_emailRegex.hasMatch(value.trim())) {
                      return "Please enter a valid email";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your password";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final messenger = ScaffoldMessenger.of(context);
                    
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await AuthService().signIn(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      // AuthChecker stream will handle redirection automatically.
                    } catch (e) {
                      if (!mounted) return;
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(e.toString().replaceAll("Exception: ", "")),
                          backgroundColor: Colors.grey.shade900,
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 20),

                // Sign up redirection
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: const Text("Create Account", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}