import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/price_model.dart';
import '../../models/mandi_model.dart';
import '../../theme/app_theme.dart';

class OperatorDashboardTab extends StatefulWidget {
  const OperatorDashboardTab({super.key});

  @override
  State<OperatorDashboardTab> createState() => _OperatorDashboardTabState();
}

class _OperatorDashboardTabState extends State<OperatorDashboardTab> {
  final _formKey = GlobalKey<FormState>();
  String _selectedCrop = 'Wheat';
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _crops = ['Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane'];

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitPrice(String mandiId) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final db = context.read<DatabaseService>();
      final newPrice = PriceModel(
        id: 'p_${DateTime.now().millisecondsSinceEpoch}',
        mandiId: mandiId,
        crop: _selectedCrop,
        price: double.parse(_priceController.text),
        date: DateTime.now(),
        timestamp: DateTime.now(),
      );

      await db.addPrice(newPrice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(LucideIcons.checkCircle2, color: Colors.white),
                SizedBox(width: 12),
                Text('Price broadcasted successfully!'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _priceController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating price: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final db = context.read<DatabaseService>();
    final MandiModel mandi = db.getMandi(user?.mandiId ?? '');

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              // Header Area
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, Operator',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mandi.name,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.mapPin,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            mandi.district,
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ).animate().fade().slideY(begin: -0.2),
                ),
              ),

              // Update Price Form Container
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceGreen,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    LucideIcons.radioTower,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Text(
                                  'Broadcast Update',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),

                            // Crop Dropdown
                            const Text(
                              'Select Commodity',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedCrop,
                              icon: const Icon(
                                LucideIcons.chevronDown,
                                color: AppTheme.textMuted,
                              ),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  LucideIcons.wheat,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                              items: _crops
                                  .map(
                                    (crop) => DropdownMenuItem(
                                      value: crop,
                                      child: Text(crop),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _selectedCrop = val!),
                            ).animate().fade(delay: 200.ms).slideX(begin: 0.1),

                            const SizedBox(height: 24),

                            // Price Input
                            const Text(
                              'Spot Price (₹ per quintal)',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'e.g. 2450',
                                prefixIcon: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Text(
                                    '₹',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Enter price';
                                if (double.tryParse(v) == null)
                                  return 'Enter valid number';
                                return null;
                              },
                            ).animate().fade(delay: 300.ms).slideX(begin: 0.1),

                            const SizedBox(height: 32),

                            // Submit Button
                            SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _submitPrice(mandi.id),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text('Publish to Grid'),
                                  ),
                                )
                                .animate()
                                .fade(delay: 400.ms)
                                .scaleY(begin: 0.8, curve: Curves.easeOutBack),
                          ],
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.1),
                ),
              ),

              // Recent Updates Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Text(
                    'Recent Broadcasts',
                    style: Theme.of(context).textTheme.titleLarge,
                  ).animate().fade(delay: 500.ms),
                ),
              ),

              // Stream for Recent Prices
              StreamBuilder<List<PriceModel>>(
                stream: db.pricesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    );
                  }

                  final prices = snapshot.data ?? [];
                  final mandiPrices = prices
                      .where((p) => p.mandiId == mandi.id)
                      .toList();

                  if (mandiPrices.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'No recent updates published.',
                            style: TextStyle(color: AppTheme.textMuted),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final price = mandiPrices[index];
                      return Container(
                            margin: const EdgeInsets.only(
                              left: 24,
                              right: 24,
                              bottom: 12,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceGreen,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Icon(
                                    LucideIcons.checkCheck,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        price.crop,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textDark,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        DateFormat(
                                          'MMM dd, hh:mm a',
                                        ).format(price.timestamp),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '₹${price.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .animate()
                          .fade(delay: Duration(milliseconds: 600 + (index * 100)))
                          .slideY(begin: 0.1);
                    }, childCount: mandiPrices.length > 3 ? 3 : mandiPrices.length),
                  );
                },
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }
}
