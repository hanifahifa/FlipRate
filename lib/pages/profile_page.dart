// ------------------------------------------------------
// PROFILE PAGE - FlipRate (Simple & Clean Version)
// ------------------------------------------------------

import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // ---------- FOTO & DATA USER ----------
            const CircleAvatar(radius: 45, backgroundColor: Color(0xFFA5D6A7)),
            const SizedBox(height: 12),
            const Text(
              'Ifa Dev',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'ifa.dev@gmail.com',
              style: TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

            // ---------- TENTANG APLIKASI ----------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tentang Aplikasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'FlipRate adalah aplikasi pemantau dan konversi kurs dunia '
                      'yang dibuat menggunakan Flutter. Aplikasi ini menampilkan '
                      'nilai tukar, tren perubahan, serta fitur konversi dan favorit '
                      'untuk membantu pengguna memantau mata uang global dengan mudah.',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sumber data: Frankfurter API (https://www.frankfurter.app)',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ---------- TOMBOL AKSI ----------
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 3,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.feedback_outlined,
                      color: Color(0xFF2E7D32),
                    ),
                    title: const Text('Kirim Feedback'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur feedback belum tersedia.'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Logout berhasil (dummy).'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
