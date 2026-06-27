import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/sos/sos_screen.dart';
import '../screens/safe_places/safe_places_screen.dart';
import 'bottom_nav_bar.dart';
import '../theme/app_colors.dart';

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SafePlacesScreen(), // Replaces generic Map
    const NotificationsScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _navigateToSOS() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SOSScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: GestureDetector(
        onTap: _navigateToSOS,
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.destructiveGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.destructive.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.emergency_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
