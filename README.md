# 💱 FlipRate – Aplikasi Pemantau & Konversi Kurs Dunia

Pantau nilai tukar, analisis tren, dan konversi mata uang real-time dalam satu aplikasi.

---

## 🌿 Deskripsi Singkat

**FlipRate** adalah aplikasi mobile berbasis **Flutter** yang berfungsi untuk memantau kurs mata uang dunia, menampilkan tren perubahan kurs, serta menghitung konversi antar mata uang.  
Aplikasi ini mengusung desain **modern berwarna hijau** untuk menggambarkan kesan finansial, stabilitas, dan kemudahan penggunaan.

---

## 🧩 Tahapan Pengerjaan

| Tahap | Fokus | Data |
|:------|:------|:------|
| 🧩 **UTS** | Desain UI, layout, navigasi, dan data dummy JSON | Lokal (JSON) |
| 🚀 **UAS (Mendatang)** | Integrasi API real-time (Frankfurter API) & fitur interaktif | API Online |

---

## 📱 Struktur Halaman Utama

| No | Halaman | Status | Tujuan Singkat |
|:--:|:--|:--:|:--|
| 1 | **Splash / Intro** | 🧩 | Pembuka & animasi logo |
| 2 | **Dashboard / Home** | 🧩 → 🚀 | Ringkasan kurs & insight |
| 3 | **Exchange List** | 🧩 → 🚀 | Daftar kurs lengkap + pencarian |
| 4 | **Analytic Page** | 🧩 → 🚀 | Grafik perubahan kurs |
| 5 | **Converter Page** | 🚀 | Menghitung konversi mata uang |
| 6 | **Favorites Page** | 🚀 | Menyimpan kurs favorit |
| 7 | **Profile Page** | 🧩 | Info pengguna & tentang aplikasi |

---

## 💚 Detail Tiap Halaman

### 🧩 1️⃣ Splash / Intro Page
- **Tujuan:** Memberi kesan profesional di awal.
- **Isi:**  
  - Logo FlipRate + animasi loading  
  - Teks: “Menyiapkan data keuanganmu 💹”  
  - Setelah 3 detik → otomatis ke Dashboard  
- **Inovatif:** Animasi logo berputar + slogan muncul bertahap.

---

### 🧩 / 🚀 2️⃣ Dashboard / Home Page
- **Fungsi:** Menampilkan ringkasan kurs & insight cepat.  
- **UTS (Dummy):** 4 kurs utama (USD, EUR, JPY, GBP) dari file JSON.  
- **UAS (Rencana):** Ambil data dari API [Frankfurter](https://api.frankfurter.app/latest).  
- **Tampilan:**
  - Kurs populer (EUR→IDR, USD→IDR, JPY→IDR)  
  - Tanggal dan waktu update  
  - Grafik mini (sparkline)  
  - Insight otomatis: *“Nilai Rupiah melemah 0.3% dibanding kemarin 💸”*  
- **Widget utama:** `ListView`, `Card`, `Row`, `Sparkline`, `BottomNavigationBar`  
- **Inovatif:** Insight otomatis + grafik mini 3 hari terakhir.

---

### 🧩 / 🚀 3️⃣ Exchange List Page
- **Fungsi:** Daftar lengkap kurs dari base EUR ke seluruh mata uang.  
- **UTS:** Data dari `kurs_dummy.json`  
- **UAS (Rencana):** API Real-time dari [Frankfurter](https://api.frankfurter.app/latest)  
- **Isi:**  
  - Search bar untuk pencarian mata uang  
  - List kurs (scrollable)  
  - Tombol “Tambah ke Favorit ⭐”  
  - Tombol refresh 🔄  
- **Widget utama:** `ListView.builder`, `SearchDelegate`, `Card`, `IconButton`  
- **Inovatif:** Pencarian dinamis + aksi cepat favorit.

---

### 🧩 / 🚀 4️⃣ Analytic Page
- **Fungsi:** Menampilkan perubahan kurs dari waktu ke waktu.  
- **UTS:** Grafik dummy 7 hari terakhir.  
- **UAS (Rencana):** Data historis dari API  
