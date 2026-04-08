import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../services/database_service.dart';
import '../../services/auth_service.dart';
import '../../models/alert_model.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    final user = auth.currentUser;

    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Price Alerts', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.surfaceWhite,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textDark),
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: db.getAlertsStream(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error loading alerts'));
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: alerts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _buildAlertCard(alert, index);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOrange.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.bellOff, size: 48, color: AppTheme.primaryOrange),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Alerts Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your personalized crop price alerts will appear here.',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ],
      ).animate().fade().slideY(begin: 0.1),
    );
  }

  Widget _buildAlertCard(AlertModel alert, int index) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(LucideIcons.zap, color: AppTheme.primaryOrange, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Alert for ${alert.crop}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
                    ),
                    Text(
                      DateFormat('MMM d, hh:mm a').format(alert.createdAt),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              if (!alert.isRead) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryOrange,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          Text(
            alert.message,
            style: const TextStyle(color: AppTheme.textDark, height: 1.5),
          ),
        ],
      ),
    ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.1);
  }
}
