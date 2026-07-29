# Daily Note V2

Daily Note V2 adalah aplikasi asisten harian produktivitas berbasis *Artificial Intelligence* (AI). Aplikasi ini didesain secara khusus untuk mencatat, mengatur, dan menyinkronkan seluruh kebutuhan harian Anda mulai dari Jadwal, Todo (Tugas), Keuangan (Pengeluaran), hingga Catatan Bebas. 

## 🌟 Fitur Utama

### 1. Asisten AI Cerdas Terintegrasi
Tidak perlu lagi mengetik secara manual di banyak formulir. Cukup ketik atau ucapkan apa yang ingin Anda lakukan di kotak *Asisten AI*, misalnya: 
- *"Besok siang jam 2 saya ada meeting dengan klien di Sudirman"*
- *"Beli makan siang habis Rp 45.000"*

AI (didukung oleh Google Gemini) akan langsung memahami niat Anda (*Intent Parsing*) dan memasukannya ke kategori **Jadwal** atau **Pengeluaran** secara otomatis!

### 2. Auto-Sinkronisasi Jadwal dari Email (Gmail Listener)
Aplikasi ini berjalan di latar belakang dan dapat memantau kotak masuk Gmail Anda secara otomatis.
- Setiap kali Anda mendapatkan email penting (misalnya: Email undangan wawancara, jadwal acara, atau *boarding pass*), AI akan membaca ringkasannya dan otomatis menjadikannya sebagai acara di **Kalender (Jadwal)** atau **Todo**.
- Anda akan mendapatkan notifikasi instan. Saat diklik, aplikasi akan langsung membuka jadwal tersebut beserta isi teks asli emailnya.

### 3. Sinkronisasi Dua Arah dengan Google Calendar
Jangan takut jadwal Anda tertinggal. 
- Saat Anda membuat jadwal baru di Daily Note, jadwal tersebut akan otomatis terunggah ke Google Calendar utama Anda.
- Sebaliknya, jika Anda menambahkan jadwal di Google Calendar, Daily Note dapat menariknya dan mencatatnya ke dalam database lokal aplikasi tanpa duplikasi ganda.

### 4. Ringkasan Harian dan Mingguan
Halaman Beranda (*Home*) memberikan ringkasan (*Overview*) yang informatif:
- Kutipan motivasi harian acak.
- Kalkulasi total pengeluaran hari ini.
- Persentase tingkat penyelesaian Todo dalam seminggu terakhir.
- *Timeline* visual agenda Anda yang akan datang hari ini.

### 5. Notifikasi Lokal & Pengingat
Setiap kali ada pembaruan atau jadwal penting, aplikasi menggunakan `flutter_local_notifications` untuk memunculkan peringatan langsung di *lock-screen* Anda.

---

## 🛠️ Teknologi yang Digunakan
- **Framework:** Flutter / Dart
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Database Lokal:** Drift (SQLite)
- **Integrasi Pihak Ketiga:**
  - `googleapis` & `google_sign_in` (Untuk Gmail API & Google Calendar API)
  - `google_generative_ai` (Untuk Pemrosesan Bahasa Alami / NLP)
  - `flutter_local_notifications` (Untuk Notifikasi Lokal)

---

## 🚀 Cara Menjalankan (Bagi Pengembang)

1. Pastikan Anda telah menginstal SDK Flutter.
2. Clone atau unduh repositori ini.
3. Jalankan `flutter pub get` untuk mengunduh semua *dependencies*.
4. **Environment Variables**:
   Buat file `.env` di direktori utama dan isi dengan kunci API Anda:
   ```env
   GEMINI_API_KEY=Kunci_Gemini_Anda_Di_Sini
   ```
5. **Konfigurasi Firebase & Google Cloud Console:**
   Pastikan Anda telah mendaftarkan *SHA-1* perangkat Anda pada *Google Cloud Console* dan **MENGAKTIFKAN (ENABLE)** layanan berikut di *GCP Project* Anda:
   - **Gmail API**
   - **Google Calendar API**
6. Jalankan proyek dengan perintah:
   ```bash
   flutter run
   ```

---

## 📝 Catatan Penting
- Saat mengaktifkan fitur Sinkronisasi Email atau Google Calendar, aplikasi akan meminta izin (*scopes*) untuk membaca email (`gmail.readonly`) dan mengelola jadwal kalender (`calendar.events`). 
- Seluruh data yang diproses disederhanakan dan dilindungi. Email tidak disebarkan ke publik, dan hanya dianalisis oleh AI (Gemini) secara sekilas demi menghemat penyimpanan dan menjaga kecepatan respon.
