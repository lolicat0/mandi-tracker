import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'farmer_dashboard_tab.dart';
import 'farmer_prices_tab.dart';
import 'farmer_prediction_tab.dart';
import '../profile/profile_tab.dart';
import '../widgets/custom_navigation_bar.dart';
import '../crop_scanner/crop_scanner_page.dart';
import '../../theme/app_theme.dart';

class FarmerMainScreen extends StatefulWidget {
  const FarmerMainScreen({super.key});

  @override
  State<FarmerMainScreen> createState() => _FarmerMainScreenState();
}

class _FarmerMainScreenState extends State<FarmerMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const FarmerDashboardTab(),
    const FarmerPricesTab(),
    const FarmerPredictionTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to scroll behind the floating nav bar
      body: _tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CropScannerPage(),
                  ),
                );
              },
              backgroundColor: AppTheme.primaryGreen,
              icon: const Icon(LucideIcons.camera, color: Colors.white),
              label: const Text(
                'Scan Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: farmerDestinations,
      ),
    );
  }
}
