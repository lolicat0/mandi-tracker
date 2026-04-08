import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/price_model.dart';
import '../../models/mandi_model.dart';
import '../../theme/app_theme.dart';

class OperatorHistoryTab extends StatelessWidget {
  const OperatorHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final MandiModel mandi = db.getMandi(user?.mandiId ?? '');

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Update History',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade().slideX(begin: -0.1),
                const SizedBox(height: 8),
                const Text(
                  'A complete timeline of your broadcasted prices.',
                  style: TextStyle(color: AppTheme.textMuted),
                ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PriceModel>>(
              stream: db.pricesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryGreen,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final prices = snapshot.data ?? [];
                final mandiPrices = prices
                    .where((p) => p.mandiId == mandi.id)
                    .toList();

                if (mandiPrices.isEmpty) {
                  return const Center(
                    child: Text(
                      'No price updates yet.',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    left: 32,
                    right: 32,
                    bottom: 100,
                  ),
                  itemCount: mandiPrices.length,
                  itemBuilder: (context, index) {
                    final price = mandiPrices[index];
                    final isLast = index == mandiPrices.length - 1;

                    return IntrinsicHeight(
                      child:
                          Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Timeline visual
                                  Column(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryGreen,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppTheme.surfaceGreen,
                                            width: 3,
                                          ),
                                        ),
                                      ),
                                      if (!isLast)
                                        Expanded(
                                          child: Container(
                                            width: 2,
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 24),
                                  // Content Card
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 24.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            DateFormat(
                                              'MMM dd, yyyy • hh:mm a',
                                            ).format(price.timestamp),
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surfaceWhite,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.01),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      LucideIcons.leaf,
                                                      color:
                                                          AppTheme.primaryGreen,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      price.crop,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text(
                                                  '₹${price.price.toStringAsFixed(0)}',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.textDark,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )
                              .animate()
                              .fade(
                                delay: Duration(
                                  milliseconds: 200 + (index * 50),
                                ),
                              )
                              .slideX(begin: 0.1),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
