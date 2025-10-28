💱 FlipRate – Aplikasi Pemantau & Konversi Kurs Dunia

FlipRate adalah aplikasi mobile berbasis Flutter yang berfungsi untuk memantau nilai tukar mata uang, melihat riwayat aktivitas konversi, serta menyimpan mata uang favorit agar pengguna dapat melakukan analisis dan perbandingan secara lebih cepat.
Aplikasi ini dirancang dengan tampilan modern, minimalis, dan fokus pada kenyamanan pengguna, sehingga cocok digunakan oleh siapa saja yang ingin memantau perubahan kurs secara real-time.

🧩 Fitur Utama

🔹 Dashboard (Home Page)
Menampilkan daftar kurs terkini antar berbagai mata uang dunia lengkap dengan simbol dan bendera negara.

🔹 Activity Page
Mencatat seluruh aktivitas konversi mata uang pengguna dalam tampilan list dinamis (menggunakan ListView.builder).

🔹 Favorite Page
Menampilkan mata uang yang telah ditandai sebagai favorit untuk akses cepat.

🔹 Profile Page
Menampilkan informasi pengguna dengan tampilan bersih dan warna lembut.

🔹 Bottom Navigation Bar (Navbar)
Navigasi utama aplikasi yang berisi empat menu utama (Dashboard, Activity, Favorite, Profile) dan tetap mengambang saat halaman digulir.

🏗️ Arsitektur & Teknologi

FlipRate dibangun menggunakan arsitektur modular Flutter dengan pendekatan pemisahan komponen berdasarkan fungsi, agar mudah dikembangkan dan dikelola.

Struktur Folder Utama:

lib/
 ├── pages/
 │   ├── dashboard_page.dart
 │   ├── activity_page.dart
 │   ├── favorite_page.dart
 │   └── profile_page.dart
 ├── widgets/
 │   └── navbar.dart
 └── main.dart


Teknologi dan Package yang Digunakan:

Flutter SDK (stable)

intl → Format tanggal dan angka

google_fonts → Menggunakan font modern SF Pro

Material Design 3 → Tampilan UI modern dan konsisten

⚙️ Cara Menjalankan

Pastikan Flutter SDK sudah terpasang.

Clone repositori:

git clone https://github.com/NAMA_ANDA/fliprate.git


Masuk ke direktori proyek:

cd fliprate


Ambil dependencies:

flutter pub get


Jalankan aplikasi:

flutter run

🚀 Roadmap & Pengembangan Selanjutnya

🔄 Integrasi API: Menghubungkan aplikasi ke API kurs dunia (Frankfurter API).

🧠 Penyimpanan Lokal: Menyimpan riwayat konversi dan favorit secara offline menggunakan SQLite.

🔍 Fitur Pencarian: Menambahkan fungsi pencarian mata uang di halaman Dashboard.

📊 Visualisasi Grafik: Menampilkan tren pergerakan kurs dalam bentuk chart interaktif.

☁️ Sinkronisasi Cloud: Menyimpan data pengguna menggunakan Firebase agar dapat diakses lintas perangkat.

📱 Tampilan Aplikasi:
