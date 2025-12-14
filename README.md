# 📱 SiRapat App - Sistem Informasi Rapat

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-3.38.0-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android)

**Aplikasi manajemen rapat terintegrasi untuk Diskominfo Badung**

[Download Latest Release](https://github.com/RanggaCasper/sirapat-app/releases/latest) • [Report Bug](https://github.com/RanggaCasper/sirapat-app/issues) • [Request Feature](https://github.com/RanggaCasper/sirapat-app/issues)

</div>

---

## 🌟 Fitur Utama

### 📋 Manajemen Rapat

- ✅ **Dashboard Rapat** - Overview rapat mendatang dan riwayat
- ✅ **Buat & Edit Rapat** - Kelola agenda rapat dengan mudah
- ✅ **Search** - Cari rapat anda dengan cepat

### 📝 Notulensi Digital

- ✅ **Notulen Realtime** - Catat hasil rapat secara digital
- ✅ **Keputusan Rapat** - Dokumentasi keputusan dan tindak lanjut

### 👥 Manajemen Peserta

- ✅ **Daftar Peserta** - Kelola undangan peserta rapat
- ✅ **Absensi QR Code** - Scan QR untuk presensi otomatis
- ✅ **Status Kehadiran** - Track konfirmasi dan kehadiran

### 🔐 Keamanan & Akses

- ✅ **Multi-role Authentication** - Admin, Master, dan Employee
- ✅ **Secure Login** - Token-based authentication
- ✅ **Profile Management** - Kelola data pribadi dan password

### 📱 Fitur Lainnya

- ✅ **Auto Update** - Cek dan install update otomatis
- ✅ **QR Code Scanner** - Untuk presensi dan share meeting

---

## 📥 Download & Install

### Method 1: GitHub Releases (Recommended)

1. Buka [Releases Page](https://github.com/RanggaCasper/sirapat-app/releases/latest)
2. Download file `app-release.apk`
3. Buka file APK di perangkat Android Anda
4. Izinkan instalasi dari sumber tidak dikenal jika diminta
5. Ikuti petunjuk instalasi

### Method 2: Build from Source

```bash
# Clone repository
git clone https://github.com/RanggaCasper/sirapat-app.git
cd sirapat-app

# Install dependencies
flutter pub get

# Build APK
flutter build apk --release

# APK akan tersedia di: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Quick Start

### Prerequisites

- Android 7.0 (API level 24) atau lebih tinggi
- Koneksi internet untuk fitur realtime
- Akun user yang sudah terdaftar di sistem

### Cara Menggunakan

#### 1️⃣ Login

```
- Masukkan email dan password Anda
- Tekan tombol "Masuk"
- Anda akan diarahkan ke dashboard
```

#### 2️⃣ Lihat Daftar Rapat

```
- Buka tab "Meeting" di bottom navigation
- Klik rapat untuk melihat detail
```

#### 3️⃣ Scan QR Absensi

```
- Buka detail meeting
- Tekan tombol "Scan QR"
- Arahkan kamera ke QR code
- Absensi otomatis tercatat
```

#### 4️⃣ Buat Notulen (Admin/Master)

```
- Buka meeting yang sedang berlangsung
- Tekan Tombol titik tiga di pojok kanan atas
- Pilih "Asisten Rapat"
- Masukan audio rekaman rapat
- Gunakan fitur transkripsi untuk mengubah audio menjadi teks
- Pastikan untuk menyunting hasil transkripsi agar sesuai dengan pembahasan rapat
- Simpan notulen setelah selesai
```

---

## 🏗️ Tech Stack

### Frontend

- **Flutter 3.38.0** - UI Framework
- **GetX** - State Management & Navigation
- **Dio** - HTTP Client
- **Socket.io** - Real-time Communication
- **QR Flutter** - QR Code Generation
- **Mobile Scanner** - QR Code Scanner
- **PDF** - PDF Generation

### Backend Integration

- **Laravel API** - RESTful Backend
- **Laravel Reverb** - WebSocket Server
- **JWT Authentication** - Secure Token Auth

### CI/CD

- **GitHub Actions** - Automated Build & Release
- **Semantic Versioning** - Version Management

---

## 📂 Project Structure

```
lib/
├── app/
│   ├── config/          # App configuration & constants
│   ├── routes/          # App routing
│   └── util/            # Utility functions
├── data/
│   ├── models/          # Data models
│   ├── providers/       # API providers
│   ├── repositories/    # Data repositories
│   └── services/        # Business logic services
├── presentation/
│   ├── controllers/     # GetX controllers
│   ├── features/        # Feature modules
│   ├── shared/          # Shared widgets
│   └── widgets/         # Common widgets
└── main.dart           # App entry point
```

---

## 🔧 Configuration

### Environment Setup

Edit `lib/app/config/app_constants.dart`:

```dart
class AppConstants {
  // Toggle between PRODUCTION and LOCAL
  static const bool isProduction = true;

  // API Endpoints
  static const String productionUrl = 'production-url';
  static const String localHost = '127.0.0.1';
  static const String localPort = '8000';
}
```

### Package Name

```
com.sirapat.diskominfo
```

---

## 🧪 Development

### Setup Development Environment

```bash
# Check Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Run app in debug mode
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze
```

### Build Variants

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release

# Specific architecture
flutter build apk --release --target-platform android-arm64
```

---

## 🤝 Contributing

Kontribusi sangat diterima! Berikut cara berkontribusi:

1. Fork repository ini
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

---

## 📝 License

Distributed under the MIT License. See `LICENSE` for more information.

---
## 👥 Team
<b>Tim PKL Diskominfo Badung 2025</b> — <i>SiRapat App</i>

<div align="center">

<table align="center">
  <tr>
    <td align="center" width="100">
      <img src="https://github.com/RanggaCasper.png" width="90" height="90" style="border-radius:50%;" /><br/>
      <b>RanggaCasper</b>
    </td>
    <td align="center" width="100">
      <img src="https://github.com/Maung90.png" width="90" height="90" style="border-radius:50%;" /><br/>
      <b>Maung90</b>
    </td>
    <td align="center" width="100">
      <img src="https://github.com/DoniJanuarW.png" width="90" height="90" style="border-radius:50%;" /><br/>
      <b>DoniJanuarW</b>
    </td>
  </tr>

  <tr>
    <td colspan="3" align="center">
      <table>
        <tr>
          <td align="center" width="100">
            <img src="https://github.com/galangdh.png" width="90" height="90" style="border-radius:50%;" /><br/>
            <b>galangdh</b>
          </td>
          <td align="center" width="100">
            <img src="https://github.com/Wildhanyaw.png" width="90" height="90" style="border-radius:50%;" /><br/>
            <b>Wildhanyaw</b>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>

</div>

---

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/)
- [GetX Package](https://pub.dev/packages/get)
- [Diskominfo Badung](https://diskominfo.badungkab.go.id/)

---

<div align="center">

**Made with ❤️ by Tim PKL Diskominfo Badung**

⭐ Star this repository if you find it helpful!

</div>
