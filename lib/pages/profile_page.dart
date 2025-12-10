// ------------------------------------------------------
// PROFILE PAGE - Refactored (Dynamic User Data)
// Menampilkan info user yang sedang login via AuthRepo
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

  // State Data User
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
    // Ambil username dari AuthRepository
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
    // 1. Tampilkan dialog konfirmasi
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // 2. Panggil Repository untuk hapus session
      await AuthRepository.logout();

      if (mounted) {
        // 3. Arahkan kembali ke halaman Login/Opening & Hapus semua route history
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

                  // ---------- FOTO & DATA USER (DINAMIS) ----------
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
                    username, // Tampilkan Username Dinamis
                    style: const TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'User Account', // Label statis karena auth simple
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------- INFO APLIKASI ----------
                  _buildInfoCard(),

                  const SizedBox(height: 20),

                  // ---------- TOMBOL AKSI (LOGOUT) ----------
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
              'Tentang Aplikasi',
              style: TextStyle(
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primaryGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'FlipRate membantu Anda memantau kurs mata uang secara real-time, melihat grafik tren, dan melakukan konversi dengan mudah.',
              style: TextStyle(fontFamily: 'SF Pro', fontSize: 14, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Versi Aplikasi: 1.0.0 (Beta)',
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
              'Kirim Masukan',
              style: TextStyle(fontFamily: 'SF Pro'),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur feedback akan segera hadir!'),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              'Keluar Akun',
              style: TextStyle(fontFamily: 'SF Pro', color: Colors.redAccent),
            ),
            onTap: _handleLogout, // Panggil fungsi logout
          ),
        ],
      ),
    );
  }
}
