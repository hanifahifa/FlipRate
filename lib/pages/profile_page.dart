// ------------------------------------------------------
// PROFILE PAGE - Refactored (Dynamic User Data)
// Displays currently logged-in user info via AuthRepo
// ------------------------------------------------------

import 'package:flutter/material.dart';
import '../../repositories/auth_repository.dart'; // Import AuthRepo

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // UI Colors
  static const Color primaryGreen = Color(0xFF043915);
  static const Color lightGreen = Color(0xFFF1F8E9);

  // User State Data
  String username = 'Guest';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // ==========================================
  // LOAD USER DATA VIA REPOSITORY
  // ==========================================
  Future<void> _loadUserData() async {
    // Get username from AuthRepository
    final user = await AuthRepository.getCurrentUser();

    if (mounted) {
      setState(() {
        username = user ?? 'Guest';
        isLoading = false;
      });
    }
  }

  // ==========================================
  // LOGOUT LOGIC
  // ==========================================
  Future<void> _handleLogout() async {
    // 1. Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'), // Translated
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'), // Translated
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'), // Translated
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 2. Call Repository to clear session
      await AuthRepository.logout();

      if (mounted) {
        // 3. Navigate back to Login/Opening & Clear route history
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGreen,
      appBar: AppBar(
        backgroundColor: primaryGreen,
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'SF Pro',
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryGreen))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // ---------- USER PHOTO & DATA (DYNAMIC) ----------
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFFA5D6A7),
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    username, // Display Dynamic Username
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'User Account',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------- APP INFO ----------
                  _buildInfoCard(),

                  const SizedBox(height: 20),

                  // ---------- ACTION BUTTONS (LOGOUT) ----------
                  _buildActionCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'About App', // Translated
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'FlipRate helps you monitor exchange rates in real-time, view trend charts, and perform conversions easily.', // Translated
              style: TextStyle(fontFamily: 'SF Pro', fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'App Version: 1.0.0 (Beta)', // Translated
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.feedback_outlined, color: primaryGreen),
            title: const Text(
              'Send Feedback', // Translated
              style: TextStyle(fontFamily: 'SF Pro'),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback feature coming soon!'), // Translated
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Logout', // Translated
              style: TextStyle(fontFamily: 'SF Pro', color: Colors.redAccent),
            ),
            onTap: _handleLogout, // Call logout function
          ),
        ],
      ),
    );
  }
}
