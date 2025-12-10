import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'widget/navbar.dart';
import 'pages/opening_page.dart';
import 'pages/auth/login_page.dart';
import 'pages/auth/register_page.dart';
import 'repositories/auth_repository.dart'; // Import repo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Cek apakah user sudah login sebelumnya?
  final bool isLoggedIn = await AuthRepository.checkLoginStatus();

  runApp(FlipRateApp(initialRoute: isLoggedIn ? '/main' : '/'));
}

class FlipRateApp extends StatelessWidget {
  final String initialRoute;
  const FlipRateApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlipRate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      // Gunakan hasil cek login tadi sebagai rute awal
      initialRoute: initialRoute, 
      
      routes: {
        '/': (context) => const OpeningPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/main': (context) => const Navbar(),
      },
    );
  }
}