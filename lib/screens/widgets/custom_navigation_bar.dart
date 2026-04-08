import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../theme/app_theme.dart';

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onDestinationSelected;
  final List<NavigationDestinationItem> destinations;

  const CustomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.textDark, // Dark slate pill
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(destinations.length, (index) {
              final isSelected = selectedIndex == index;
              final dest = destinations[index];
              return GestureDetector(
                onTap: () => onDestinationSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 20.0 : 12.0,
                    vertical: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        dest.icon,
                        color: isSelected ? Colors.white : Colors.white54,
                        size: 24,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          dest.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class NavigationDestinationItem {
  final IconData icon;
  final String label;

  const NavigationDestinationItem(this.icon, this.label);
}

// Helper to provide standard farmer destinations
List<NavigationDestinationItem> get farmerDestinations => const [
  NavigationDestinationItem(LucideIcons.home, 'Home'),
  NavigationDestinationItem(LucideIcons.lineChart, 'Prices'),
  NavigationDestinationItem(LucideIcons.sparkles, 'AI'),
  NavigationDestinationItem(LucideIcons.user, 'Profile'),
];

// Helper to provide standard operator destinations
List<NavigationDestinationItem> get operatorDestinations => const [
  NavigationDestinationItem(LucideIcons.layoutDashboard, 'Panel'),
  NavigationDestinationItem(LucideIcons.history, 'Logs'),
  NavigationDestinationItem(LucideIcons.user, 'Profile'),
];
