# 💱 FlipRate – Smart Currency Converter & Tracker

**FlipRate** adalah aplikasi mobile berbasis Flutter yang dirancang untuk memantau nilai tukar mata uang secara *real-time*, menganalisis tren pasar melalui grafik interaktif, dan melakukan konversi mata uang dengan presisi.

Aplikasi ini dibangun menggunakan prinsip **Clean Architecture** (memisahkan UI, Repository, dan Service) serta menerapkan mekanisme **API Fallback** untuk menjamin data selalu tersedia meskipun salah satu penyedia layanan sedang *down*.

---

## 🌟 Fitur Unggulan

### 1. 🏠 Smart Dashboard
* **Real-time Rates:** Menampilkan nilai tukar mata uang populer (USD, EUR, JPY, SGD) terhadap IDR.
* **Trend Chart:** Grafik interaktif (menggunakan `fl_chart`) yang menampilkan pergerakan harga 3-4 hari terakhir untuk analisis tren.
* **Smart Refresh:** Fitur *pull-to-refresh* yang memperbarui data pasar dan grafik sekaligus.

### 2. 🔁 Konversi & Riwayat (Activity)
* **Instant Conversion:** Konversi mata uang dengan dukungan *Cross-Rate* (menghitung nilai tukar silang secara otomatis).
* **Local History:** Riwayat konversi disimpan secara lokal menggunakan `shared_preferences`, sehingga pengguna bisa melihat aktivitas terakhir mereka.
* **Smart Filter:** Cari mata uang dengan mudah berdasarkan kode atau nama negara.

### 3. ⭐ Favorite Watchlist
* Menandai mata uang favorit untuk pemantauan cepat.
* Indikator visual (Hijau 📈 / Merah 📉) untuk melihat kenaikan atau penurunan harga secara instan.

### 4. 📊 Market Analysis
* **Top Gainers & Losers:** Menganalisis mata uang mana yang paling menguat dan melemah dalam 24 jam terakhir.
* **Market Insight:** Memberikan sinyal "Bullish" atau "Bearish" berdasarkan data pergerakan harga.

### 5. 🔔 Notification System
* Sistem simulasi notifikasi yang memberitahu pengguna jika terjadi perubahan harga signifikan pada mata uang favorit.

---

## 🏗️ Arsitektur & Teknologi

FlipRate dibangun dengan struktur **Clean Architecture** untuk memastikan kode mudah dikelola (*maintainable*) dan skalabel.

### Struktur Folder
```text
lib/
├── main.dart               # Entry point & Routing Logic
├── models/                 # Model Data (JSON Serialization)
├── pages/                  # Halaman UI Utama
│   ├── auth/               # Login & Register
│   ├── addPages/           # Halaman Detail (DetailRatePage)
│   └── ...                 # Dashboard, Activity, Favorite, Profile
├── repositories/           # Business Logic & Data Processing (Otak Aplikasi)
├── services/               # Raw API Call Logic (HTTP Request)
├── utils/                  # Helper (FavoriteManager, HistoryManager)
└── widget/                 # Reusable Components (Navbar, ChartCard, etc)

**Teknologi dan Package yang Digunakan:**
- **Flutter SDK (stable)**
- **intl** → Format tanggal dan angka
- **google_fonts** → Menggunakan font modern SF Pro
- **Material Design 3** → Tampilan UI modern dan konsisten

---
## ⚙️ Cara Menjalankan Aplikasi

Ikuti langkah-langkah berikut untuk menjalankan proyek ini di mesin lokal Anda (pastikan berada di branch `uas`):

1. **Pastikan Flutter SDK sudah terpasang.**
2. Clone repositori ini:
   ```bash
   git clone [https://github.com/hanifahifa/FlipRate](https://github.com/hanifahifa/FlipRate)

3. Masuk ke direktori proyek:
   ```Bash
   cd FlipRate

4. Pindah ke branch UAS (Penting):
   ```Bash
   git checkout uas

5. Ambil semua dependencies:
   ```Bash
   flutter pub get

6.Jalankan aplikasi di emulator atau perangkat nyata:
   ```Bash
   flutter run


## 🚀 Status Fitur & Roadmap

Berdasarkan versi pengembangan terkini (Branch `uas`), berikut adalah status realisasi fitur dalam aplikasi FlipRate:

### ✅ Fitur Terealisasi (Sudah Ada)
- [x] **Sistem Autentikasi & Akun:**
  - Login & Register dengan validasi input dan animasi transisi.
  - **Reset Password** (Simulasi logika pemulihan akun).
  - Mekanisme Logout & Session management.
- [x] **Dashboard & Monitoring:**
  - Integrasi API Real-time untuk kurs mata uang.
  - **Grafik Interaktif (Chart)** untuk memantau tren nilai tukar (USD to IDR).
  - **Fitur Notifikasi** untuk pembaruan aplikasi/kurs.
- [x] **Manajemen Favorit:**
  - Menambah dan menghapus mata uang ke daftar pantauan.
  - Kalkulasi kenaikan/penurunan persentase kurs secara otomatis.
- [x] **Aktivitas & Riwayat:**
  - Mencatat riwayat konversi (*Conversion History*).
  - Menyimpan daftar mata uang yang baru dilihat (*Recently Viewed*).
  - *Smart Insight* memberikan wawasan berdasarkan data lokal.
- [x] **Antarmuka Pengguna (UI/UX):**
  - Desain modern dengan animasi *Fade & Slide*.
  - *Crash Handling* (Penanganan error) saat pengambilan data gagal.

### 🔜 Rencana Pengembangan Selanjutnya (Future Work)
Fitur-fitur berikut direncanakan untuk pengembangan di masa depan (Versi 2.0):
- [ ] **Mode Gelap (Dark Mode):** Dukungan tema gelap otomatis mengikuti sistem.
- [ ] **Dukungan Multi-Bahasa:** Penambahan opsi Bahasa Inggris dan Indonesia secara penuh.
- [ ] **Feedback System:** Formulir pengiriman masukan pengguna ke server backend.

  ---

  ## 📱 Tampilan Aplikasi
<img width="399" height="845" alt="Screenshot 2025-10-28 222900" src="https://github.com/user-attachments/assets/aeef841b-bff4-4591-8653-9cb1ec61ce19" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194034" src="https://github.com/user-attachments/assets/aaeaec6c-2e86-44da-a913-e4a0ce41484f" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194312" src="https://github.com/user-attachments/assets/e8a97335-a4b9-4d73-a523-1a618d559d9c" />
<img width="399" height="845" alt="Screenshot 2025-10-28 194325" src="https://github.com/user-attachments/assets/3987c696-09ca-4d3f-b3db-548db4fd808e" />




