import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/data/services/version_checker_service.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateDialog extends StatelessWidget {
  final VersionCheckResult versionInfo;

  const UpdateDialog({super.key, required this.versionInfo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.system_update,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text('Update Tersedia'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionInfo(
              'Versi Saat Ini',
              versionInfo.currentVersion,
              Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildVersionInfo(
              'Versi Terbaru',
              versionInfo.latestVersion,
              Colors.green,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            const Text(
              'Catatan Rilis:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                versionInfo.releaseNotes.isNotEmpty
                    ? versionInfo.releaseNotes
                    : 'Tidak ada catatan rilis',
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Nanti')),
        ElevatedButton.icon(
          onPressed: () => _openReleaseUrl(context),
          icon: const Icon(Icons.download, size: 18),
          label: const Text('Update Sekarang'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVersionInfo(String label, String version, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            'v$version',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openReleaseUrl(BuildContext context) async {
    final url = versionInfo.apkDownloadUrl ?? versionInfo.releaseUrl;

    // Validasi URL
    if (url.isEmpty) {
      _showError('URL download tidak tersedia');
      return;
    }

    try {
      final uri = Uri.parse(url);

      // Cek apakah URL valid
      if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
        _showError('URL tidak valid');
        return;
      }

      // Cek apakah bisa membuka URL
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        _showError(
          'Tidak dapat membuka browser. Silakan cek pengaturan aplikasi Anda.',
        );
        return;
      }

      // Buka URL
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched) {
        Get.back();
      } else {
        _showError('Gagal membuka halaman download');
      }
    } on FormatException catch (e) {
      dev.log('Invalid URL format: $url', error: e, name: 'UpdateDialog');
      _showError('Format URL tidak valid');
    } catch (e, stackTrace) {
      dev.log(
        'Error opening URL: $url',
        error: e,
        stackTrace: stackTrace,
        name: 'UpdateDialog',
      );
      _showError('Terjadi kesalahan saat membuka halaman download');
    }
  }

  void _showError(String message) {
    try {
      Get.find<NotificationController>().showError(message);
    } catch (e) {
      dev.log(
        'Failed to show error notification: $message',
        error: e,
        name: 'UpdateDialog',
      );
    }
  }

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
        Get.dialog(UpdateDialog(versionInfo: result), barrierDismissible: true);
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
