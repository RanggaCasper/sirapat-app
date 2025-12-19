# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.7] - 2025-12-19

### Fixed
* Fix Summary Page budget display issues.

## [1.0.6] - 2025-12-18

### Added

* Displayed Start Time and End Time on meeting list cards to improve scheduling visibility.

### Fixed

* User state synchronization: enforced reactive UI updates after profile or division changes.
* Secure logout: integrated local logout with the `auth/logout` server endpoint to revoke active tokens.
* Admin meeting list: resolved backend integration issues when fetching administrative meeting data.

### Improved

* Chat UI: refined message bubble styling and layout for a cleaner communication experience.
* Real-time profile data: implemented auto-refresh and pull-to-refresh on the Personal Information page.

### Removed

* Unnecessary badges from the meeting participant list to simplify the interface.

## [1.0.5] - 2025-12-16

### Fixed

* UI SafeArea issues on bottom sheets.

### Improved

* Bottom sheet interaction and gesture-safe spacing.
* Minor UI spacing and padding refinements.

### Added

* Sharing meeting information via QR Code.

### Technical

* Refactored UI components for improved SafeArea handling.

## [1.0.4] - 2025-12-16

### Added

* Export meeting minutes to PDF.

## [1.0.3] - 2025-12-15

### Fixed

* WebSocket auto-reconnect when disconnected.
* Backend role assignment issue.
* Truncated error messages in chat.
* Incorrect sender name on incoming messages.
* Chat input hidden by on-screen keyboard.

### Improved

* Automatic scroll to the latest chat message.
* Real-time listener stability after reconnection.

## [1.0.2] - 2025-12-15

### Changed

* Updated API base URL to the production environment.

## [1.0.1] - 2025-12-15

### Added

* Update Meeting Minutes feature.

## [1.0.0] - 2025-12-14

### Added

* Auto-update feature to check and install the latest APK version.
* Meeting dashboard with upcoming meetings and full history.
* Digital meeting minutes with real-time collaboration.
* Participant management for invitations and attendance.
* QR Code scanner for attendance and meeting sharing.
* Multi-role authentication (Admin, Master, Employee).
* Audio transcription using AI.
* Real-time data synchronization via WebSocket (Laravel Reverb).
* Search and filter functionality for meetings.
* Modern and user-friendly UI/UX.

### Changed

* Package name changed from `com.example.sirapat_app` to `com.sirapat.diskominfo`.
* QR scanner optimization: gallery picker no longer stores cache files.
* Dynamic versioning using PackageInfo Plus.

### Fixed

* Android 15 compatibility for APK installation.
* Resolved all Flutter analyze issues (0 issues remaining).
* All automated tests passing.
* Permission handling for Android 7.0 and above.

### Security

* Token-based authentication using JWT.
* Secured API endpoints.
* Encrypted password storage.

## [Unreleased]

### Planned Features

* Email notifications for meeting invitations.
* Google Calendar integration.
* Multi-language support (ID/EN).
* Push notifications for meeting reminders.

---

[1.0.6]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.6
[1.0.5]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.5
[1.0.4]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.4
[1.0.3]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.3
[1.0.2]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.2
[1.0.1]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.1
[1.0.0]: https://github.com/RanggaCasper/sirapat-app/releases/tag/v1.0.0