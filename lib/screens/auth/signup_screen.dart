import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _villageController = TextEditingController();
  final _cropController = TextEditingController();
  final _mandiIdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _role = 'farmer'; // 'farmer' or 'operator'
  bool _isLoading = false;

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (_role == 'farmer') {
        await context.read<AuthService>().signupAsFarmer(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          village: _villageController.text.trim(),
          preferredCrop: _cropController.text.trim(),
        );
      } else {
        await context.read<AuthService>().signupAsOperator(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          mandiId: _mandiIdController.text.trim(),
        );
      }
      if (mounted) {
        Navigator.pop(context); // Go back after sign up
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryGreen,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Create Account',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: isWide ? AppTheme.textDark : Colors.white,
                              ),
                            ).animate().fade().slideY(begin: 0.2, curve: Curves.easeOut),
                            const SizedBox(height: 8),
                            Text(
                              'Select your role to get started.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isWide ? AppTheme.textMuted : Colors.white70,
                              ),
                            ).animate().fade(delay: 100.ms).slideY(begin: 0.2, curve: Curves.easeOut),

                            const SizedBox(height: 40),

                            // Main Signup Card Form
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
                                          isSelected: _role == 'farmer',
                                          onTap: () => setState(() => _role = 'farmer'),
                                        ),
                                        _AnimatedRoleTab(
                                          title: 'Operator',
                                          isSelected: _role == 'operator',
                                          onTap: () => setState(() => _role = 'operator'),
                                        ),
                                      ],
                                    ),
                                  ).animate().fade(delay: 200.ms).slideY(begin: 0.1),

                                  const SizedBox(height: 32),

                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: 'Full Name',
                                      prefixIcon: const Icon(LucideIcons.user),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ).animate().fade(delay: 300.ms).slideX(begin: 0.1),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration(
                                      labelText: 'Phone Number',
                                      prefixIcon: const Icon(LucideIcons.phone),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ).animate().fade(delay: 350.ms).slideX(begin: 0.1),
                                  const SizedBox(height: 16),

                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Password',
                                      prefixIcon: const Icon(LucideIcons.lock),
                                    ),
                                    validator: (v) => v!.isEmpty ? 'Required' : null,
                                  ).animate().fade(delay: 400.ms).slideX(begin: 0.1),
                                  const SizedBox(height: 16),

                                  if (_role == 'farmer') ...[
                                    TextFormField(
                                      controller: _villageController,
                                      decoration: InputDecoration(
                                        labelText: 'Village / Location',
                                        prefixIcon: const Icon(LucideIcons.mapPin),
                                      ),
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ).animate().fade(delay: 450.ms).slideX(begin: 0.1),
                                    const SizedBox(height: 16),
                                    TextFormField(
                                      controller: _cropController,
                                      decoration: InputDecoration(
                                        labelText: 'Primary Crop',
                                        prefixIcon: const Icon(LucideIcons.leaf),
                                      ),
                                    ).animate().fade(delay: 500.ms).slideX(begin: 0.1),
                                  ] else ...[
                                    TextFormField(
                                      controller: _mandiIdController,
                                      decoration: InputDecoration(
                                        labelText: 'Mandi ID',
                                        prefixIcon: const Icon(LucideIcons.store),
                                      ),
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ).animate().fade(delay: 450.ms).slideX(begin: 0.1),
                                  ],

                                  const SizedBox(height: 48),

                                  ElevatedButton(
                                    onPressed: _isLoading ? null : _signup,
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Create Account'),
                                  ).animate().fade(delay: 600.ms).scaleY(begin: 0.9, curve: Curves.easeOutBack),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
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
