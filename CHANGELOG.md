# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.5] - 2025-12-16
### 🐛 Fixed
- 📱 UI SafeArea issues on bottom sheet

### ⚡ Improved
- 📐 Bottom sheet interaction and gesture-safe spacing
- 🎨 Minor UI spacing and padding refinements

### ✨ Added
- 🔳 Share meeting information via QR Code

### 🔧 Technical
- Refactored UI components for better SafeArea handling

## [1.0.4] - 2025-12-16
### Added
- 📊 Export notulen ke PDF

## [1.0.3] - 2025-12-15
### 🐛 Fixed
- 🔌 WebSocket auto-reconnect when disconnected
- 🧩 Backend role assignment issue
- ✂️ Truncated error messages in chat
- 👤 Incorrect sender name on incoming messages
- ⌨️ Chat input hidden by keyboard

### ⚡ Improved
- ⬇️ Auto-scroll chat to latest message
- 🔄 Realtime listener stability after reconnect

## [1.0.2] - 2025-12-15
### Changed
- 🔑 Updated API base URL to production environment

## [1.0.1] - 2025-12-15
### Added
- ✅ Implements Update Meeting Minutes feature

## [1.0.0] - 2025-12-14

### Added
- ✨ **Auto-Update Feature** - Aplikasi otomatis cek update dan install APK versi terbaru
- 📱 **Dashboard Rapat** - Overview rapat mendatang dan riwayat lengkap
- 📝 **Notulensi Digital** - Catat hasil rapat secara digital dengan realtime
- 👥 **Manajemen Peserta** - Kelola undangan dan absensi peserta rapat
- 📋 **QR Code Scanner** - Scan QR untuk presensi otomatis dan share meeting
- 🔐 **Multi-role Authentication** - Support untuk Admin, Master, dan Employee
- 🎤 **Transkripsi Audio** - Fitur AI untuk mengubah audio rekaman menjadi notulen
- 🔄 **Real-time Sync** - Sinkronisasi data menggunakan WebSocket (Laravel Reverb)
- 📊 **Search & Filter** - Cari dan filter rapat dengan mudah
- 🎨 **Modern UI/UX** - Interface yang clean dan user-friendly

### Changed
- 🔧 Package name diubah dari `com.example.sirapat_app` menjadi `com.sirapat.diskominfo`
- ⚡ Optimasi QR Scanner - Gallery picker tidak menyimpan file cache
- 📱 Dynamic versioning menggunakan PackageInfo Plus

### Fixed
- 🐛 Android 15 compatibility untuk instalasi APK
- ✅ Fix semua flutter analyze issues (0 issues)
- ✅ All tests passing (5/5 tests)
- 🔐 Permission handling untuk Android 7.0+

### Security
- 🔒 Token-based authentication dengan JWT
- 🛡️ Secure API endpoints
- 🔐 Password encryption

## [Unreleased]

### Planned Features
- 📧 Email notification untuk undangan rapat
- 📅 Integrasi dengan Google Calendar
- 🌐 Multi-language support (ID/EN)
- 🔔 Push notifications untuk reminder rapat

---

[1.0.5]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.5
[1.0.4]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.4
[1.0.3]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.3
[1.0.2]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.2
[1.0.1]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.1
[1.0.0]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.0
