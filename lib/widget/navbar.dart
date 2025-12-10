import 'package:flutter/material.dart';
import 'dart:ui';
import '../pages/dashboard_page.dart';
import '../pages/activity_page.dart';
import '../pages/favorite_page.dart';
import '../pages/profile_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;

  final _pages = const [
    DashboardPage(),
    ActivityPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Warna yang digunakan:
    final Color darkGreen = const Color(0xFF043915);
    final Color borderColor = const Color(0xFF054d1c);

    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
        height: 80,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: Container(
              decoration: BoxDecoration(
                // Latar belakang hijau tua dengan transparansi
                color: darkGreen.withOpacity(0.85),
                borderRadius: BorderRadius.circular(35),

                // Border hijau
                border: Border.all(
                  color: borderColor.withOpacity(0.5),
                  width: 1.0,
                ),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.receipt_long_rounded,
                    label: 'Activity',
                    index: 1,
                  ),
                  _buildNavItem(
                    icon: Icons.star_rounded,
                    label: 'Favorite',
                    index: 2,
                  ),
                  _buildNavItem(
                    icon: Icons.person_rounded,
                    label: 'Profile',
                    index: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final greenColor = const Color(0xFF043915);
    final selectedBgColor = Colors.white.withOpacity(0.3);

    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? greenColor : Colors.white.withOpacity(0.7),
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  color: isSelected
                      ? greenColor
                      : Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: 0,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
