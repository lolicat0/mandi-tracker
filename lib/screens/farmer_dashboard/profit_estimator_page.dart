import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';

class ProfitEstimatorPage extends StatefulWidget {
  const ProfitEstimatorPage({super.key});

  @override
  State<ProfitEstimatorPage> createState() => _ProfitEstimatorPageState();
}

class _ProfitEstimatorPageState extends State<ProfitEstimatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _cropCtrl = TextEditingController();
  final _quantityCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _transportCtrl = TextEditingController();

  double? _netProfit;

  void _calculateProfit() {
    if (_formKey.currentState!.validate()) {
      final quantity = double.tryParse(_quantityCtrl.text) ?? 0;
      final price = double.tryParse(_priceCtrl.text) ?? 0;
      final transport = double.tryParse(_transportCtrl.text) ?? 0;

      setState(() {
        _netProfit = (price * quantity) - transport;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Profit Estimator', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _cropCtrl,
                      decoration: const InputDecoration(labelText: 'Crop Name', prefixIcon: Icon(LucideIcons.leaf)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _quantityCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Quantity (Quintals)', prefixIcon: Icon(LucideIcons.scale)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price per Quintal (₹)', prefixIcon: Icon(LucideIcons.banknote)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _transportCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Total Transport Cost (₹)', prefixIcon: Icon(LucideIcons.truck)),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _calculateProfit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Calculate Profit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fade().slideY(begin: 0.1),

            if (_netProfit != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.secondaryGreen]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryGreen.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('Estimated Net Profit', style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${_netProfit!.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
            ]
          ],
        ),
      ),
    );
  }
}
