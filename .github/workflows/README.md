# GitHub Actions Workflows

## Build and Release Workflow

Workflow ini akan otomatis:
1. Build Android APK (Debug & Release)
2. Build Android App Bundle
3. Build iOS IPA (tanpa code signing)
4. Upload artifacts
5. Membuat GitHub Release saat tag `v*` dipush

### Cara Menggunakan

#### 1. Build Otomatis
Workflow akan berjalan otomatis ketika:
- Push ke branch `main`, `master`, atau `develop`
- Membuat Pull Request ke `main` atau `master`
- Push tag yang dimulai dengan `v` (contoh: `v1.0.0`)

#### 2. Membuat Release Manual

Untuk membuat release baru:

```bash
# Update versi di pubspec.yaml terlebih dahulu
# Contoh: version: 1.0.1+2

# Commit perubahan
git add pubspec.yaml
git commit -m "Bump version to 1.0.1"
git push

# Buat tag
git tag v1.0.1
git push origin v1.0.1
```

Setelah tag dipush, GitHub Actions akan:
- Build aplikasi
- Membuat release baru di GitHub
- Upload APK dan AAB ke release

#### 3. Manual Trigger

Anda juga bisa menjalankan workflow secara manual:
1. Buka tab "Actions" di GitHub repository
2. Pilih "Build and Release Flutter App"
3. Klik "Run workflow"
4. Pilih branch dan klik "Run workflow"

### Artifacts

Setiap build akan menghasilkan artifacts:
- `android-apk-debug` - APK Debug
- `android-apk-release` - APK Release
- `android-appbundle` - Android App Bundle (.aab)
- `ios-ipa` - iOS IPA (jika berhasil)

### Setup Required

Tidak diperlukan konfigurasi tambahan! Workflow menggunakan:
- `GITHUB_TOKEN` (otomatis tersedia)
- Public repository (untuk akses API)

### Customization

Edit file `.github/workflows/build.yml` untuk:
- Mengubah versi Flutter
- Menambah target platform
- Mengubah konfigurasi build
- Menambahkan step tambahan (testing, linting, dll)
