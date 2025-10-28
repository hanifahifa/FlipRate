import 'package:flutter/material.dart';
import '../pages/dashboard_page.dart';
import '../pages/activity_page.dart';
import '../pages/favorite_page.dart';
import '../pages/profile_page.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;

  final _pages = const [
    DashboardPage(),
    ActivityPage(),
    FavoritePage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2E7D32),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: Colors.white,
            unselectedItemColor: const Color(0xFFADD99B),
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontFamily: 'SF Pro',fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: const TextStyle(fontFamily: 'SF Pro'),
            items: const [BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),activeIcon: Icon(Icons.home),label: 'Dashboard',
              ),BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),activeIcon: Icon(Icons.receipt_long),label: 'Activity',
              ),BottomNavigationBarItem(
                icon: Icon(Icons.star_border),activeIcon: Icon(Icons.star),label: 'Favorite',
              ),BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),activeIcon: Icon(Icons.person),label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
