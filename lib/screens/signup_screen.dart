import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  static const Set<String> _personalDomains = {
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'live.com',
    'icloud.com',
  };
  
  String _selectedRole = 'student'; // Default role
  bool _isLoading = false;

  bool _isCollegeEmail(String email) {
    final normalized = email.trim().toLowerCase();
    if (!_emailRegex.hasMatch(normalized)) {
      return false;
    }

    final domain = normalized.split('@').last;
    return !_personalDomains.contains(domain);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.fastfood_rounded,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  "Join Canteen Ease",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Order food seamlessly or manage your canteen",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Name Field
                TextFormField(
                  controller: nameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your name";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your college email";
                    }
                    if (!_isCollegeEmail(value)) {
                      return "Use a valid college email (not personal email)";
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: "College Email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return "Password must be at least 6 characters";
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

                // Role Selector
                Text(
                  "I am registering as:",
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.school, size: 18),
                            SizedBox(width: 8),
                            Text("Student"),
                          ],
                        ),
                        selected: _selectedRole == 'student',
                        selectedColor: theme.colorScheme.primaryContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRole = 'student';
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.store, size: 18),
                            SizedBox(width: 8),
                            Text("Staff"),
                          ],
                        ),
                        selected: _selectedRole == 'staff',
                        selectedColor: theme.colorScheme.primaryContainer,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedRole = 'staff';
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Signup Button
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final messenger = ScaffoldMessenger.of(context);
                    final navigator = Navigator.of(context);
                    
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      await AuthService().signUp(
                        name: nameController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                        role: _selectedRole,
                      );
                      if (!mounted) return;

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text("Account created successfully."),
                          backgroundColor: Colors.black,
                        ),
                      );
                      navigator.pop();
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
                      : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}