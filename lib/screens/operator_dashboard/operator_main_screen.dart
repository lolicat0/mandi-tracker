import 'package:flutter/material.dart';
import 'operator_dashboard_tab.dart';
import '../profile/profile_tab.dart';
import 'operator_history_tab.dart';
import '../widgets/custom_navigation_bar.dart';

class OperatorMainScreen extends StatefulWidget {
  const OperatorMainScreen({super.key});

  @override
  State<OperatorMainScreen> createState() => _OperatorMainScreenState();
}

class _OperatorMainScreenState extends State<OperatorMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const OperatorDashboardTab(),
    const OperatorHistoryTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _tabs[_currentIndex],
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: operatorDestinations,
      ),
    );
  }
}
