# 🕌 ShalatKu

Aplikasi Flutter untuk jadwal shalat, arah kiblat, Al-Quran Digital, dan tracker ibadah harian dengan dukungan Pencarian Makna berbasis AI.

**Dibuat oleh:** Ath Thahir Muhammad Isa Rahmatullah — NRP 5025231181  
**Kontak:** [wa.me/+6285331238980](https://wa.me/+6285331238980)

---

## 🎬 Demo Video

Tonton demo presentasi aplikasi di sini:

[![ShalatKu Demo](https://img.youtube.com/vi/cBjhd9NWtc8/maxresdefault.jpg)](https://youtu.be/cBjhd9NWtc8 "ShalatKu - Prayer Times & Worship Tracker App")

**Link:** [https://youtu.be/cBjhd9NWtc8](https://youtu.be/cBjhd9NWtc8)

---

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| 🤖 **Pencarian Makna AI** | Fitur AI Search cerdas dan spesifik untuk:<br>• **Pencarian Ayat Al-Quran**<br>• **Pencarian Tafsir**<br>• **Pencarian Surat**<br>• **Pencarian Doa**<br>• **Pencarian Makna/Konteks**<br>Didukung dengan Semantic Search yang akurat dari Equran.id Vector API. |
| 📖 **Al-Quran Digital** | Membaca 114 Surah lengkap dengan teks Arab, Latin, Terjemahan, dan Tafsir. |
| 🕌 **Jadwal Shalat 8 Waktu** | Imsak, Subuh, Terbit, Dhuha, Dzuhur, Ashar, Maghrib, Isya dengan kalkulasi real-time. |
| 🧭 **Arah Kiblat** | Kompas realtime menggunakan sensor magnetik device dan perhitungan koordinat GPS. |
| 📿 **Worship Tracker** | Mencatat progres ibadah harian (Shalat, Dzikir, Sedekah, dll) dengan sistem CRUD lengkap. |
| 📊 **Statistik & Visualisasi** | Laporan perkembangan ibadah mingguan/bulanan dalam bentuk Pie dan Bar Chart. |
| 🔔 **Notifikasi Adzan** | Pengingat otomatis untuk setiap waktu shalat yang dapat dikustomisasi. |
| 🔐 **Cloud Synchronization** | Sinkronisasi data aman menggunakan Firebase Authentication dan Cloud Firestore. |

---

## ✅ Mini Project Requirements (40%)

| Requirement | Status | Detail |
|------------|--------|--------|
| **CRUD dengan Relational Database** | ✓ | Implementasi CRUD log ibadah di Cloud Firestore. |
| **Firebase Authentication** | ✓ | Sistem Login dan Register yang aman. |
| **Penyimpanan Data Firebase** | ✓ | Persistensi data user dan log ibadah secara real-time. |
| **Notifikasi** | ✓ | Notifikasi adzan terjadwal dan pengingat kustom. |
| **Smartphone Resources** | ✓ | Integrasi GPS untuk lokasi dan Magnetometer untuk Kiblat. |
| **Demo Video & GitHub** | ✓ | Dokumentasi lengkap via Video dan Repository. |

---

## 🚀 Setup & Instalasi

### 1. Prasyarat
- Flutter SDK ≥ 3.0
- Proyek Firebase yang sudah dikonfigurasi.
- FlutterFire CLI terinstal.

### 2. Langkah Instalasi
```bash
# Clone repository
git clone https://github.com/Attoher/shalatku-flutter.git

# Masuk ke direktori
cd shalatku

# Install dependencies
flutter pub get

# Konfigurasi Firebase
flutterfire configure
```

### 3. Konfigurasi Platform
- **Android:** Pastikan permission `ACCESS_FINE_LOCATION` dan `RECEIVE_BOOT_COMPLETED` ada di `AndroidManifest.xml`.
- **iOS:** Tambahkan `NSLocationWhenInUseUsageDescription` di `Info.plist`.

---

## 🗂️ Struktur Proyek

```
lib/
├── core/                        # Konfigurasi dasar & Theme
├── data/                        # Data Layer (Models & Repositories)
├── models/                      # Business Models
├── providers/                   # State Management (Provider)
├── services/                    # External Services (Firebase, API, GPS)
├── screens/                     # UI Pages
│   ├── auth/                    # Login & Register
│   ├── home/                    # Dashboard & Center Screens
│   ├── ibadah/                  # Log Ibadah & CRUD
│   ├── prayer_times/            # Jadwal Shalat
│   ├── qibla/                   # Kompas Kiblat
│   ├── quran/                   # List, Detail, & AI Search
│   └── profile/                 # Pengaturan & Profil
├── widgets/                     # Reusable Components
└── main.dart                    # Entry Point
```

---

## 📦 Dependensi Utama

- `firebase_auth` & `cloud_firestore`: Backend & Database.
- `adhan`: Kalkulasi waktu shalat presisi.
- `flutter_compass` & `geolocator`: Sensor device.
- `flutter_local_notifications`: Sistem pengingat.
- `fl_chart`: Visualisasi data statistik.
- `provider`: Manajemen state aplikasi.
- `http`: Integrasi API Al-Quran & Vector Search.

---

## 🛡️ Keamanan & Privasi

- **Firebase Security Rules:** Menjamin setiap pengguna hanya bisa mengakses data mereka sendiri.
- **Permission Handling:** Meminta izin akses lokasi dan notifikasi hanya saat dibutuhkan secara transparan.

---

## 📚 Credits

- **Al-Quran API:** [Equran.id](https://equran.id/apidev) - Penyedia data Al-Quran & AI Vector Search.
- **Inspirasi UI:** Modern Islamic Design Patterns.
