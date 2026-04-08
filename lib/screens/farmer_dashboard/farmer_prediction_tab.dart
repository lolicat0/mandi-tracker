import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

class FarmerPredictionTab extends StatelessWidget {
  const FarmerPredictionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<DatabaseService>();
    final List<String> availableCrops = [
      'Wheat',
      'Rice',
      'Maize',
      'Cotton',
      'Sugarcane',
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header Area
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AI Predictions',
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade().slideX(begin: -0.1),
                  const SizedBox(height: 8),
                  const Text(
                    'Plan your harvest with data-driven insights.',
                    style: TextStyle(color: AppTheme.textMuted),
                  ).animate().fade(delay: 100.ms).slideX(begin: -0.1),
                ],
              ),
            ),
          ),

          // Cards List
          SliverPadding(
            padding: const EdgeInsets.only(
              left: 24.0,
              right: 24.0,
              bottom: 100.0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final crop = availableCrops[index];
                final prediction = db.getMockPrediction(crop);

                // Determine styling based on prediction sentiment
                IconData sentimentIcon;
                Color sentimentColor;
                Color bgColor;

                if (prediction.toLowerCase().contains('increase')) {
                  sentimentIcon = LucideIcons.trendingUp;
                  sentimentColor = AppTheme.secondaryGreen;
                  bgColor = AppTheme.surfaceGreen;
                } else if (prediction.toLowerCase().contains('drop') ||
                    prediction.toLowerCase().contains('decrease')) {
                  sentimentIcon = LucideIcons.trendingDown;
                  sentimentColor = Colors.redAccent;
                  bgColor = const Color(0xFFFEF2F2);
                } else {
                  sentimentIcon = LucideIcons.minus;
                  sentimentColor = AppTheme.primaryOrange;
                  bgColor = AppTheme.surfaceOrange;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child:
                      Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: bgColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Icon(
                                              sentimentIcon,
                                              color: sentimentColor,
                                              size: 20,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Text(
                                            crop,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFEEF2FF,
                                          ), // Soft Indigo
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              LucideIcons.zap,
                                              size: 12,
                                              color: Color(0xFF4F46E5),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '85% Conf.',
                                              style: TextStyle(
                                                color: Color(0xFF4F46E5),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.background,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          LucideIcons.sparkles,
                                          color: AppTheme.primaryGreen,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            prediction,
                                            style: const TextStyle(
                                              color: AppTheme.textDark,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .fade(
                            delay: Duration(milliseconds: 200 + (index * 100)),
                          )
                          .slideY(begin: 0.1),
                );
              }, childCount: availableCrops.length),
            ),
          ),
        ],
      ),
    );
  }
}
