import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _selectedRole = 'farmer';

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().login(
        _phoneController.text.trim(),
        _passwordController.text.trim(),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;
          return Stack(
            children: [
              // Gradient Header Background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: isWide ? 400 : 320,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),
              ),

              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardTheme.color ?? Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  LucideIcons.leaf,
                                  size: 48,
                                  color: AppTheme.primaryGreen,
                                ),
                              ).animate().scale(
                                duration: 500.ms,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Mandi Tracker',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: isWide ? AppTheme.textDark : Colors.white,
                              ),
                            ).animate().fade().slideY(begin: 0.2, curve: Curves.easeOut),
                            const SizedBox(height: 8),
                            Text(
                              'Real-time Market Insights',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isWide ? AppTheme.textMuted : Colors.white70,
                              ),
                            ).animate().fade(delay: 100.ms).slideY(begin: 0.2, curve: Curves.easeOut),

                            const SizedBox(height: 40),

                            // Main Login Card Form
                            Container(
                              padding: const EdgeInsets.all(32),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color ?? Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 24,
                                    spreadRadius: 0,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Role Toggle
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        _AnimatedRoleTab(
                                          title: 'Farmer',
                                          isSelected: _selectedRole == 'farmer',
                                          onTap: () => setState(() => _selectedRole = 'farmer'),
                                        ),
                                        _AnimatedRoleTab(
                                          title: 'Operator',
                                          isSelected: _selectedRole == 'operator',
                                          onTap: () => setState(() => _selectedRole = 'operator'),
                                        ),
                                      ],
                                    ),
                                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                                  const SizedBox(height: 32),

                                  // Phone Input
                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: const Icon(LucideIcons.phone),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
                                  ).animate().fade(delay: 300.ms).slideX(begin: 0.1),

                                  const SizedBox(height: 20),

                                  // Password Input
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(LucideIcons.lock),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Enter password' : null,
                                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1),

                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {}, // Forgot password placeholder
                                      child: const Text('Forgot password?'),
                                    ),
                                  ).animate().fade(delay: 500.ms),

                                  const SizedBox(height: 32),

                                  // Login Button
                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Sign In'),
                                  ).animate().fade(delay: 600.ms).scaleY(begin: 0.9, curve: Curves.easeOutBack),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Signup Route
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: isWide ? AppTheme.textMuted : Colors.white,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                                    );
                                  },
                                  child: const Text('Create one'),
                                ),
                              ],
                            ).animate().fade(delay: 700.ms),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnimatedRoleTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedRoleTab({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? (Theme.of(context).cardTheme.color ?? Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
