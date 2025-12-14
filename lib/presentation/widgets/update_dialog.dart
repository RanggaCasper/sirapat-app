import 'dart:developer' as dev;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/data/services/version_checker_service.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class UpdateBottomSheet extends StatefulWidget {
  final VersionCheckResult versionInfo;

  const UpdateBottomSheet({super.key, required this.versionInfo});

  @override
  State<UpdateBottomSheet> createState() => _UpdateBottomSheetState();
}

class _UpdateBottomSheetState extends State<UpdateBottomSheet> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: BottomSheetHandle(margin: EdgeInsets.only(bottom: 12)),
            ),
            _buildHeader(),
            const SizedBox(height: 24),
            _buildVersionInfo(),
            const SizedBox(height: 20),
            _buildReleaseNotes(),
            const SizedBox(height: 24),
            if (_isDownloading) _buildDownloadProgress(),
            if (!_isDownloading) _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.system_update,
            size: 48,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Update Tersedia',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Versi baru aplikasi telah tersedia',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          _buildVersionRow(
            'Versi Saat Ini',
            widget.versionInfo.currentVersion,
            Colors.grey,
          ),
          const SizedBox(height: 12),
          const Icon(Icons.arrow_downward, color: Colors.grey, size: 20),
          const SizedBox(height: 12),
          _buildVersionRow(
            'Versi Terbaru',
            widget.versionInfo.latestVersion,
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String version, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReleaseNotes() {
    final releaseNotes = widget.versionInfo.releaseNotes.isNotEmpty
        ? widget.versionInfo.releaseNotes
        : 'Perbaikan bug dan peningkatan performa';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apa yang Baru:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 200, // Batasi tinggi untuk scroll
          ),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Markdown(
            data: releaseNotes,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            styleSheet: MarkdownStyleSheet(
              p: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black87,
              ),
              h1: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              h2: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              h3: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              listBullet: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
              ),
              code: TextStyle(
                backgroundColor: Colors.grey.shade200,
                color: Colors.black87,
                fontSize: 12,
              ),
              codeblockDecoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadProgress() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _downloadProgress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 12),
        Text(
          _downloadStatus,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text(
              'Nanti Saja',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _downloadAndInstall,
            icon: const Icon(Icons.download, size: 20),
            label: const Text(
              'Update Sekarang',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadAndInstall() async {
    final apkUrl = widget.versionInfo.apkDownloadUrl;

    if (apkUrl == null || apkUrl.isEmpty) {
      _showError('URL download tidak tersedia');
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Memulai download...';
    });

    try {
      final dio = Dio();

      // Untuk Android 15, gunakan app-specific directory yang tidak butuh permission
      // kemudian copy ke Downloads setelah selesai (jika memungkinkan)
      Directory downloadDir;

      if (Platform.isAndroid) {
        // Coba gunakan folder Download publik terlebih dahulu
        try {
          final publicDownloads = Directory('/storage/emulated/0/Download');
          if (await publicDownloads.exists()) {
            downloadDir = publicDownloads;
          } else {
            // Fallback ke app-specific external storage
            final externalDir = await getExternalStorageDirectory();
            downloadDir = externalDir!;
          }
        } catch (e) {
          // Jika gagal, gunakan app-specific directory
          final externalDir = await getExternalStorageDirectory();
          downloadDir = externalDir!;
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      final fileName = 'sirapat_app_v${widget.versionInfo.latestVersion}.apk';
      final filePath = '${downloadDir.path}/$fileName';

      dev.log(
        'Downloading APK to: $filePath',
        name: 'UpdateBottomSheet',
      );

      // Delete old file if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await dio.download(
        apkUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() {
              _downloadProgress = received / total;
              final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
              final totalMB = (total / 1024 / 1024).toStringAsFixed(1);
              _downloadStatus = 'Mendownload... $receivedMB MB / $totalMB MB';
            });
          }
        },
      );

      setState(() {
        _downloadStatus = 'Download selesai. Membuka installer...';
      });

      // Tunggu sebentar untuk memastikan file tersimpan dengan benar
      await Future.delayed(const Duration(milliseconds: 800));

      // Verifikasi file ada dan ukurannya benar
      final downloadedFile = File(filePath);
      if (!await downloadedFile.exists()) {
        _showError('File APK tidak ditemukan setelah download');
        return;
      }

      final fileSize = await downloadedFile.length();
      dev.log(
        'APK file ready: $filePath (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
        name: 'UpdateBottomSheet',
      );

      Get.back();

      // Buka installer APK secara otomatis
      dev.log(
        'Opening APK installer: $filePath',
        name: 'UpdateBottomSheet',
      );

      final result = await OpenFilex.open(filePath);

      dev.log(
        'OpenFilex result: ${result.type} - ${result.message}',
        name: 'UpdateBottomSheet',
      );

      // Berikan feedback ke user
      if (result.type == ResultType.done) {
        _showSuccess(
          'Installer APK telah dibuka. Silakan klik "Install" untuk melanjutkan.',
        );
      } else if (result.type == ResultType.noAppToOpen) {
        _showSuccess(
          'File APK tersimpan. Installer akan terbuka dalam beberapa saat.',
        );
      } else if (result.type == ResultType.permissionDenied) {
        _showError(
          'Izin ditolak! Mohon aktifkan "Install unknown apps" untuk aplikasi ini:\n'
          '1. Buka Settings\n'
          '2. Pilih Apps → SiRapat App\n'
          '3. Aktifkan "Install unknown apps"',
        );
      } else if (result.type == ResultType.fileNotFound) {
        _showError('File APK tidak ditemukan. Silakan coba download ulang.');
      } else {
        _showError(
          'Installer tidak dapat dibuka otomatis. '
          'File tersimpan di: ${downloadDir.path}\n'
          'Silakan buka folder Download dan install manual.',
        );
      }
    } catch (e, stackTrace) {
      dev.log(
        'Error downloading APK',
        error: e,
        stackTrace: stackTrace,
        name: 'UpdateBottomSheet',
      );
      _showError('Gagal mendownload update: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _showError(String message) {
    try {
      Get.find<NotificationController>().showError(message);
    } catch (e) {
      dev.log(
        'Failed to show error notification: $message',
        error: e,
        name: 'UpdateBottomSheet',
      );
    }
  }

  void _showSuccess(String message) {
    try {
      Get.find<NotificationController>().showSuccess(message);
    } catch (e) {
      dev.log(
        'Failed to show success notification: $message',
        error: e,
        name: 'UpdateBottomSheet',
      );
    }
  }
}

class UpdateDialog {
  static Future<void> checkAndShowUpdate({
    required String repoOwner,
    required String repoName,
    bool forceShow = false,
  }) async {
    try {
      final versionChecker = VersionCheckerService(
        repoOwner: repoOwner,
        repoName: repoName,
      );

      final result = await versionChecker.checkForUpdate();

      if (result.hasUpdate) {
        Get.bottomSheet(
          UpdateBottomSheet(versionInfo: result),
          isDismissible: true,
          enableDrag: true,
          isScrollControlled: true,
        );
      } else if (forceShow) {
        // Tidak ada update tersedia, tapi user melakukan pengecekan manual
        Get.find<NotificationController>().showSuccess(
          'Aplikasi Anda sudah menggunakan versi terbaru (v${result.currentVersion})',
        );
      }
    } on Exception catch (e, stackTrace) {
      dev.log(
        'Failed to check for updates',
        error: e,
        stackTrace: stackTrace,
        name: 'UpdateDialog',
      );

      if (forceShow) {
        String errorMessage;

        // Berikan pesan error yang lebih spesifik
        if (e.toString().contains('Network error') ||
            e.toString().contains('SocketException')) {
          errorMessage =
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.';
        } else if (e.toString().contains('404')) {
          errorMessage =
              'Repository tidak ditemukan. Periksa konfigurasi aplikasi.';
        } else if (e.toString().contains('403') ||
            e.toString().contains('401')) {
          errorMessage =
              'Akses ditolak. Mungkin ada batasan rate limit dari GitHub.';
        } else if (e.toString().contains('timeout')) {
          errorMessage = 'Koneksi timeout. Coba lagi dalam beberapa saat.';
        } else {
          errorMessage = 'Gagal memeriksa update. Silakan coba lagi nanti.';
        }

        try {
          Get.find<NotificationController>().showError(errorMessage);
        } catch (notifError) {
          dev.log(
            'Failed to show notification: $errorMessage',
            error: notifError,
            name: 'UpdateDialog',
          );
        }
      }
    }
  }
}
