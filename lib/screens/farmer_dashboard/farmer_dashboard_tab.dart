import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/price_model.dart';
import '../../models/alert_model.dart';
import '../../theme/app_theme.dart';
import 'crop_scanner_dialog.dart';
import 'profit_estimator_page.dart';
import 'alerts_screen.dart';

class FarmerDashboardTab extends StatelessWidget {
  const FarmerDashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final user = auth.currentUser;
    final db = context.read<DatabaseService>();

    // Mock: Generate a daily alert whenever the dashboard builds
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        db.generateDailyAlertForUser(user);
      });
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              // Header & Greeting
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Welcome back,',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.name.split(' ').first ?? 'Farmer',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.textMuted,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ).animate().fade().slideY(begin: -0.2),
                      
                      // Notification Bell
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AlertsScreen()));
                        },
                        child: StreamBuilder<List<AlertModel>>(
                          stream: user != null ? db.getAlertsStream(user.uid) : const Stream.empty(),
                          builder: (context, snapshot) {
                            final alertCount = snapshot.data?.where((a) => !a.isRead).length ?? 0;
                            return Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceWhite,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(LucideIcons.bell, color: AppTheme.textDark),
                                ),
                                if (alertCount > 0)
                                  Positioned(
                                    right: 8,
                                    top: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          }
                        ),
                      ).animate().fade(delay: 200.ms).scale(curve: Curves.easeOutBack),
                    ],
                  ),
                ),
              ),

              // Live Alerts Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceOrange,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.primaryOrange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.zap, color: AppTheme.primaryOrange, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            "Live Alert: Prices rising in nearby Mandis today!",
                            style: TextStyle(
                              color: Color(0xFFB45309), // Darker orange text
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fade(delay: 300.ms).slideX(begin: 0.1),
                ),
              ),

              // Main Content Stream
              StreamBuilder<List<PriceModel>>(
                stream: db.pricesStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return _buildSkeletonLoader();
                  }

                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('Error: ${snapshot.error}')),
                    );
                  }

                  final prices = snapshot.data ?? [];
                  if (prices.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text('No mandi data available right now.')),
                    );
                  }

                  final targetCrop = user?.preferredCrop ?? prices.first.crop;
                  final myCropPrices = prices.where((p) => p.crop.toLowerCase() == targetCrop.toLowerCase()).toList();
                  
                  final latestPrice = myCropPrices.isNotEmpty ? myCropPrices.first.price : prices.first.price;
                  final bestPrice = prices.where((p) => p.crop.toLowerCase() == targetCrop.toLowerCase()).fold<double>(0, (max, p) => p.price > max ? p.price : max);
                  
                  final prediction = db.getMockPrediction(targetCrop);

                  return SliverList(
                    delegate: SliverChildListDelegate([
                      _buildThreeStatCards(context, latestPrice, bestPrice, prediction, targetCrop),
                      
                      // Demand Indicator & Crop Scanner Buttons
                      _buildActionSection(context),

                      _buildPriceChart(context, prices, targetCrop),
                      
                      ..._buildRecentUpdatesList(context, db, prices),
                      const SizedBox(height: 100), // Bottom nav padding
                    ]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- SKELETON LOADER ---
  Widget _buildSkeletonLoader() {
    return SliverList(
      delegate: SliverChildListDelegate([
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ],
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fade(begin: 0.5, end: 1.0, duration: 1.seconds),
      ]),
    );
  }

  // --- 3 ANALYTICS CARDS (Responsive Wrapping) ---
  Widget _buildThreeStatCards(BuildContext context, double latestPrice, double bestPrice, String prediction, String targetCrop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 500;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isWide ? (constraints.maxWidth - 32) / 3 : (constraints.maxWidth - 16) / 2,
                child: _AnimatedMetricCard(
                  title: "Today's Price",
                  value: '₹${latestPrice.toStringAsFixed(0)}',
                  subtitle: targetCrop,
                  icon: LucideIcons.trendingUp,
                  gradientColors: const [AppTheme.primaryGreen, AppTheme.secondaryGreen],
                ).animate().fade().slideY(begin: 0.2),
              ),
              SizedBox(
                width: isWide ? (constraints.maxWidth - 32) / 3 : (constraints.maxWidth - 16) / 2,
                child: _AnimatedMetricCard(
                  title: 'Best Nearby',
                  value: '₹${bestPrice.toStringAsFixed(0)}',
                  subtitle: 'Top Recommendation',
                  icon: LucideIcons.mapPin,
                  gradientColors: const [Color(0xFF0284C7), Color(0xFF38BDF8)], // Blue Gradient
                ).animate().fade(delay: 100.ms).slideY(begin: 0.2),
              ),
              SizedBox(
                width: isWide ? (constraints.maxWidth - 32) / 3 : constraints.maxWidth,
                child: _AnimatedMetricCard(
                  title: 'AI Prediction',
                  value: 'Rising', // Simplified for the metric card
                  subtitle: 'Expected +5% tomorrow',
                  icon: LucideIcons.sparkles,
                  gradientColors: const [AppTheme.primaryOrange, Color(0xFFFBBF24)], // Orange Gradient
                ).animate().fade(delay: 200.ms).slideY(begin: 0.2),
              ),
            ],
          );
        }
      ),
    );
  }

  // --- ACTION SECTION (Demand indicator & Scanner) ---
  Widget _buildActionSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
          // Demand Indicator
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppTheme.secondaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Market Demand',
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        Text(
                          'High',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fade(delay: 300.ms),
          ),
          const SizedBox(width: 16),
          // Crop Quality Scanner Button
          Expanded(
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const CropScannerDialog(),
                );
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F46E5), Color(0xFF6366F1)], // Indigo Gradient
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.camera, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Scan Crop',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ).animate().fade(delay: 400.ms),
          ),
            ],
          ),
          const SizedBox(height: 16),
          // Profit Estimator Button
          InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitEstimatorPage()));
            },
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(LucideIcons.calculator, color: AppTheme.primaryOrange, size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Profit Estimator',
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 16),
                          ),
                          Text(
                            'Calculate net profit',
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Icon(LucideIcons.chevronRight, color: AppTheme.textMuted),
                ],
              ),
            ),
          ).animate().fade(delay: 450.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  // --- LINE CHART SECTION ---
  Widget _buildPriceChart(BuildContext context, List<PriceModel> prices, String targetCrop) {
    // Generate mock graph data points
    final targetPrices = prices.where((p) => p.crop == targetCrop).toList();
    final basePrice = targetPrices.isNotEmpty ? targetPrices.first.price : 2000.0;

    final spots = [
      FlSpot(0, basePrice - 100),
      FlSpot(1, basePrice - 50),
      FlSpot(2, basePrice + 20),
      FlSpot(3, basePrice - 10),
      FlSpot(4, basePrice + 80),
      FlSpot(5, basePrice + 40),
      FlSpot(6, basePrice), // Today
    ];

    double minY = (basePrice - 200).floorToDouble();
    double maxY = (basePrice + 200).ceilToDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Price Trend',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    targetCrop,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 100,
                    getDrawingHorizontalLine: (value) => const FlLine(color: Color(0xFFF1F5F9), strokeWidth: 1),
                  ),
                  titlesData: const FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0, maxX: 6, minY: minY, maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppTheme.secondaryGreen,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.secondaryGreen.withValues(alpha: 0.3),
                            AppTheme.secondaryGreen.withValues(alpha: 0.0),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fade(delay: 500.ms).slideY(begin: 0.1),
    );
  }

  // --- RECENT UPDATES LIST ---
  List<Widget> _buildRecentUpdatesList(BuildContext context, DatabaseService db, List<PriceModel> prices) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Text(
          'Nearby Mandis Output',
          style: Theme.of(context).textTheme.titleLarge,
        ).animate().fade(delay: 600.ms),
      ),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: prices.length > 5 ? 5 : prices.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final price = prices[index];
          final mandi = db.getMandi(price.mandiId);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceGreen,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(child: Icon(LucideIcons.store, color: AppTheme.primaryGreen, size: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mandi.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${price.crop} • ${DateFormat('hh:mm a').format(price.timestamp)}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${price.price.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryGreen),
                    ),
                    const Text('/qtl', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ).animate().fade(delay: Duration(milliseconds: 700 + (index * 100))).slideY(begin: 0.1);
        },
      ),
    ];
  }
}

// --- ANIMATED METRIC CARD UTILITY ---
class _AnimatedMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;

  const _AnimatedMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.3),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
