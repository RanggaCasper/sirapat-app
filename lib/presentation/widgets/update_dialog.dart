import 'dart:developer' as dev;
import 'dart:io';
import 'dart:async';

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

/// In-memory store to retain download progress when the bottom sheet is closed
/// and reopened during the same app session.
class DownloadProgressStore {
  static bool isDownloading = false;
  static double progress = 0.0;
  static String status = '';
  static String? apkUrl;
  static String? tempPath;
  static String? finalPath;

  // Broadcast stream so UI can subscribe when reopened
  static final StreamController<Map<String, dynamic>> _ctrl =
      StreamController<Map<String, dynamic>>.broadcast();

  static Stream<Map<String, dynamic>> get stream => _ctrl.stream;

  static void _notify() {
    try {
      _ctrl.add({
        'isDownloading': isDownloading,
        'progress': progress,
        'status': status,
        'apkUrl': apkUrl,
        'tempPath': tempPath,
        'finalPath': finalPath,
      });
    } catch (_) {}
  }

  static void reset() {
    isDownloading = false;
    progress = 0.0;
    status = '';
    apkUrl = null;
    tempPath = null;
    finalPath = null;
    _notify();
  }

  /// Start download in background (app lifetime). Multiple UI listeners
  /// can subscribe to `DownloadProgressStore.stream` to receive live updates.
  static Future<void> startDownload(String apkUrl) async {
    // If same download already running, ignore
    if (isDownloading && DownloadProgressStore.apkUrl == apkUrl) return;

    isDownloading = true;
    progress = 0.0;
    status = 'Memulai download...';
    DownloadProgressStore.apkUrl = apkUrl;
    tempPath = null;
    finalPath = null;
    _notify();

    final dio = Dio();

    try {
      Directory baseDir;
      if (Platform.isAndroid) {
        try {
          baseDir = (await getExternalStorageDirectory())!;
        } catch (_) {
          baseDir = await getApplicationDocumentsDirectory();
        }
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      final fileName = 'sirapat_app.apk';
      final fPath = '${baseDir.path}/$fileName';
      final tPath = '${baseDir.path}/$fileName.tmp';

      tempPath = tPath;
      finalPath = fPath;
      _notify();

      final tempFile = File(tPath);
      final finalFile = File(fPath);

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      await dio.download(
        apkUrl,
        tPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            progress = received / total;
            final r = (received / 1024 / 1024).toStringAsFixed(1);
            final t = (total / 1024 / 1024).toStringAsFixed(1);
            status = 'Mendownload... $r MB / $t MB';
            _notify();
          }
        },
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      if (!await tempFile.exists() || await tempFile.length() == 0) {
        throw Exception('File hasil download tidak valid');
      }

      if (await finalFile.exists()) {
        await finalFile.delete();
      }

      await tempFile.rename(fPath);

      progress = 1.0;
      status = 'Download selesai';
      isDownloading = false;
      tempPath = tPath;
      finalPath = fPath;
      _notify();

      // Try to open installer; show notifications via NotificationController
      try {
        final result = await OpenFilex.open(fPath);

        if (result.type == ResultType.done) {
          try {
            Get.find<NotificationController>().showSuccess(
              'Installer APK terbuka. Silakan lanjutkan instalasi.',
            );
          } catch (_) {}
        } else if (result.type == ResultType.permissionDenied) {
          try {
            Get.find<NotificationController>().showError(
              'Izin ditolak. Aktifkan "Install unknown apps" di Settings.',
            );
          } catch (_) {}
        } else {
          try {
            Get.find<NotificationController>().showError(
              'Installer tidak bisa dibuka otomatis. File tersimpan di:\n$fPath',
            );
          } catch (_) {}
        }
      } catch (e) {
        // ignore open errors but keep finalPath for user
      }
    } on DioException catch (e) {
      isDownloading = false;
      status = 'Gagal mendownload: ${e.message}';
      _notify();
      try {
        Get.find<NotificationController>()
            .showError('Gagal mendownload update: ${e.message}');
      } catch (_) {}
    } catch (e) {
      isDownloading = false;
      status = 'Gagal mendownload: $e';
      _notify();
      try {
        Get.find<NotificationController>()
            .showError('Gagal mendownload update: $e');
      } catch (_) {}
    }
  }
}

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
  StreamSubscription<Map<String, dynamic>>? _storeSub;

  @override
  void initState() {
    super.initState();

    // Restore progress if a download is already in progress for the same APK
    _isDownloading = DownloadProgressStore.isDownloading &&
        (DownloadProgressStore.apkUrl == widget.versionInfo.apkDownloadUrl);
    _downloadProgress = DownloadProgressStore.progress;
    _downloadStatus = DownloadProgressStore.status;

    // Listen for live updates from the shared store so reopening sheet
    // shows continuous progress updates.
    _storeSub = DownloadProgressStore.stream.listen((snapshot) {
      try {
        if (snapshot['apkUrl'] == widget.versionInfo.apkDownloadUrl) {
          if (mounted) {
            setState(() {
              _isDownloading = snapshot['isDownloading'] as bool? ?? false;
              _downloadProgress = snapshot['progress'] as double? ?? 0.0;
              _downloadStatus = snapshot['status'] as String? ?? '';
            });
          }
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _storeSub?.cancel();
    super.dispose();
  }

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
      child: SafeArea(
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
              if (!_isDownloading) _buildActions()
            ],
          ),
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
          'Pembaruan Tersedia',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
              color: Colors.black87),
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
    return Row(
      children: [
        Expanded(
          child: _buildVersionCard(
            'Versi Saat Ini',
            widget.versionInfo.currentVersion,
            Colors.grey,
            Colors.grey.shade50,
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_forward,
            color: Colors.grey,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildVersionCard(
            'Versi Terbaru',
            widget.versionInfo.latestVersion,
            Colors.green,
            Colors.green.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildVersionCard(
    String label,
    String version,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Text(
              'v$version',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
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
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(
            maxHeight: 200,
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
              'Abaikan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
              'Perbarui Sekarang',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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

    // Update UI immediately and start background download via shared store.
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
      _downloadStatus = 'Memulai download...';
    });

    // Kick off download in background store (it updates the store as it progresses)
    DownloadProgressStore.startDownload(apkUrl);
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
