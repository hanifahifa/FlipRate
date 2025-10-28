# 💱 FlipRate – Aplikasi Pemantau & Konversi Kurs Dunia

FlipRate adalah aplikasi mobile berbasis Flutter yang berfungsi untuk **memantau nilai tukar mata uang**, **melihat riwayat aktivitas konversi**, serta **menyimpan mata uang favorit** agar pengguna dapat melakukan analisis dan perbandingan secara lebih cepat.  
Aplikasi ini dirancang dengan tampilan **modern, minimalis, dan fokus pada kenyamanan pengguna**, sehingga cocok digunakan oleh siapa saja yang ingin memantau perubahan kurs secara real-time.

---

## 🧩 Fitur Utama

🔹 **Dashboard (Home Page)**  
Menampilkan daftar kurs terkini antar berbagai mata uang dunia lengkap dengan simbol dan bendera negara.

🔹 **Activity Page**  
Mencatat seluruh aktivitas konversi mata uang pengguna dalam tampilan list dinamis menggunakan `ListView.builder`.

🔹 **Favorite Page**  
Menampilkan mata uang yang telah ditandai sebagai favorit untuk akses cepat.

🔹 **Profile Page**  
Menampilkan informasi pengguna dengan tampilan bersih dan warna lembut.

🔹 **Bottom Navigation Bar (Navbar)**  
Navigasi utama aplikasi yang berisi empat menu utama (Dashboard, Activity, Favorite, Profile) dan tetap mengambang saat halaman digulir.

---

## 🏗️ Arsitektur & Teknologi

FlipRate dibangun menggunakan arsitektur **modular Flutter** dengan pendekatan pemisahan komponen berdasarkan fungsi, agar mudah dikembangkan dan dikelola.

**Struktur Folder:**
- `pages` : Halaman utama aplikasi (`DashboardPage`, `ActivityPage`, `FavoritePage`, `ProfilePage`).
- `widgets` : Widget kustom yang dapat digunakan ulang (`Navbar`).
- `models` : Model data (jika nanti ditambahkan API atau data lokal).
- `services` : Tempat logika pengambilan data (akan digunakan setelah integrasi API).


**Teknologi dan Package yang Digunakan:**
- **Flutter SDK (stable)**
- **intl** → Format tanggal dan angka
- **google_fonts** → Menggunakan font modern SF Pro
- **Material Design 3** → Tampilan UI modern dan konsisten

---

## ⚙️ Cara Menjalankan

1. Pastikan **Flutter SDK** sudah terpasang.
2. Clone repositori:
   ```bash
   git clone https://github.com/NAMA_ANDA/fliprate.git
3. Masuk ke direktori proyek:
   ```bash
   cd fliprate
4. Ambil semua dependencies:
   ```bash
   flutter pub get
5. Jalankan aplikasi di emulator atau perangkat nyata:
      ```bash
   flutter run


  ---

## Roadmap & Pengembangan Selanjutnya

Proyek FlipRate masih berada pada tahap pengembangan awal dan direncanakan akan terus dikembangkan dengan penambahan fitur serta peningkatan performa. Beberapa rencana pengembangan selanjutnya meliputi:

- Integrasi API real-time untuk menampilkan data kurs mata uang secara langsung.  
- Penambahan fitur grafik interaktif guna memantau tren nilai tukar.  
- Implementasi sistem autentikasi pengguna.  
- Optimalisasi tampilan antarmuka agar lebih responsif dan menarik.  
- Penambahan fitur riwayat transaksi serta penyimpanan preferensi pengguna.  
- Penerapan mode gelap (dark mode) dan personalisasi tema.

  ---

  ## 📱 Tampilan Aplikasi
<img width="399" height="845" alt="Screenshot 2025-10-28 222900" src="https://github.com/user-attachments/assets/aeef841b-bff4-4591-8653-9cb1ec61ce19" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194034" src="https://github.com/user-attachments/assets/aaeaec6c-2e86-44da-a913-e4a0ce41484f" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194312" src="https://github.com/user-attachments/assets/e8a97335-a4b9-4d73-a523-1a618d559d9c" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194325" src="https://github.com/user-attachments/assets/3987c696-09ca-4d3f-b3db-548db4fd808e" />




