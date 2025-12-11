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
```
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

6. Jalankan aplikasi di emulator atau perangkat nyata:
   ```Bash
   flutter run
   ```


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
![Screenshot_2025-12-11-15-59-40-19_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/6e7d1eb8-5d01-492a-a217-c78977d72783)
![Screenshot_2025-12-11-15-59-46-20_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/3a76d05e-a040-4f4e-bdbe-bb25dda917d5)
![Screenshot_2025-12-11-15-59-43-02_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/395fb393-f126-41da-bf37-1a75af803e72)
![Screenshot_2025-12-11-15-58-44-43_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/422f4d1f-b43c-41bb-8c65-98c31c911fbe)
![Screenshot_2025-12-11-15-58-52-99_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/280f148e-a6cc-425f-9449-fc2de730a65a)
![Screenshot_2025-12-11-15-58-56-72_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/da0d5fe1-dae4-46a8-8cc3-d4b995aaccb3)
![Screenshot_2025-12-11-15-59-28-90_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/ffa9cd51-ad3a-4296-8aa8-bf1443ec41f6)
![Screenshot_2025-12-11-15-59-18-42_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/04fc019b-7170-4fe3-bfc3-c076214d75e1)
![Screenshot_2025-12-11-15-59-10-00_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/89d4a405-da07-468e-95c4-1cd2b9f7ad79)
![Screenshot_2025-12-11-15-59-05-63_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/beb21d07-d23b-404a-90d7-d96807c557a0)
![Screenshot_2025-12-11-15-58-59-64_cfc59e53ef3a746a150a639154ce5d2a](https://github.com/user-attachments/assets/2efd05d5-cb66-45f9-8406-9af2bad05b1f)





