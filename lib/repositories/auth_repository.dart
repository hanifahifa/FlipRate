import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  // Key untuk menyimpan siapa yang SEDANG login sekarang
  static const String keyCurrentUser = 'current_active_user';
  
  // Prefix untuk kunci password setiap user
  // Contoh penyimpanan nanti: 'account_ifa' -> '12345'
  static const String prefixAccount = 'account_';

  // ------------------------------------------
  // REGISTER (Mendukung Banyak User)
  // ------------------------------------------
  static Future<bool> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Cek apakah username sudah ada?
    final accountKey = '$prefixAccount$username';
    if (prefs.containsKey(accountKey)) {
      // Opsional: Return false jika tidak ingin menimpa akun yang sudah ada
      // Tapi untuk simpel, kita biarkan menimpa (update password)
    }

    // Simpan: Kuncinya 'account_ifa', Isinya 'passwordnya'
    await prefs.setString(accountKey, password);
    
    // Otomatis login setelah register (Opsional, tapi memudahkan)
    await prefs.setString(keyCurrentUser, username);
    
    return true; 
  }

  // ------------------------------------------
  // LOGIN (Cek Database Lokal)
  // ------------------------------------------
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Ambil password yang tersimpan untuk username ini
    final accountKey = '$prefixAccount$username';
    final savedPassword = prefs.getString(accountKey);

    // 1. Cek apakah user ada?
    if (savedPassword == null) {
      return false; // User tidak ditemukan (Harus register dulu)
    }

    // 2. Cek apakah password cocok?
    if (savedPassword == password) {
      // Jika cocok, simpan sesi bahwa user ini sedang login
      await prefs.setString(keyCurrentUser, username);
      return true;
    }
    
    return false; // Password salah
  }

  // ------------------------------------------
  // LOGOUT
  // ------------------------------------------
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Hapus sesi login saat ini, TAPI JANGAN hapus data akun (username/pass)
    await prefs.remove(keyCurrentUser);
  }

  // ------------------------------------------
  // CEK STATUS LOGIN (Untuk main.dart)
  // ------------------------------------------
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // Cek apakah ada data di 'current_active_user'
    return prefs.containsKey(keyCurrentUser);
  }
  
  // ------------------------------------------
  // AMBIL USERNAME YANG SEDANG LOGIN
  // ------------------------------------------
  static Future<String?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyCurrentUser);
  }
}