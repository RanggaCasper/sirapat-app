import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:sirapat_app/data/providers/network/api_endpoint.dart';
import 'package:sirapat_app/data/providers/network/api_provider.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class MeetingReportController extends GetxController {
  final APIProvider _apiProvider = Get.find<APIProvider>();
  final LocalStorageService _storage = Get.find<LocalStorageService>();

  // Notification helper
  NotificationController get _notif => Get.find<NotificationController>();

  // Observable variables
  final isLoading = false.obs;
  final downloadProgress = 0.0.obs;
  final isDownloading = false.obs;

  // Date range for filtering
  final Rx<DateTime> startDate =
      DateTime.now().subtract(const Duration(days: 30)).obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[MeetingReportController] Controller initialized');
  }

  // Format date to yyyy-MM-dd
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Update start date
  void updateStartDate(DateTime date) {
    startDate.value = date;

    // Ensure start date is not after end date
    if (startDate.value.isAfter(endDate.value)) {
      endDate.value = startDate.value;
    }
  }

  // Update end date
  void updateEndDate(DateTime date) {
    endDate.value = date;

    // Ensure end date is not before start date
    if (endDate.value.isBefore(startDate.value)) {
      startDate.value = endDate.value;
    }
  }

  // Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.isGranted) {
        return true;
      }

      final status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 13+ (API 33+), try photos permission
      if (await Permission.photos.isGranted) {
        return true;
      }

      final photosStatus = await Permission.photos.request();
      return photosStatus.isGranted;
    }

    return true; // iOS doesn't need storage permission for app directory
  }

  // Download meeting report PDF
  Future<void> downloadMeetingReport() async {
    try {
      isLoading.value = true;
      isDownloading.value = true;
      downloadProgress.value = 0.0;

      // Request storage permission
      final hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        _notif.showError('Izin penyimpanan diperlukan untuk mengunduh file');
        return;
      }

      // Prepare query parameters
      final queryParams = {
        'start_date': _formatDate(startDate.value),
        'end_date': _formatDate(endDate.value),
      };

      debugPrint(
          '[MeetingReportController] Downloading report with params: $queryParams');

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        // Try to use Downloads/SiRapat/Report folder
        final downloadsPath = '/storage/emulated/0/Download/SiRapat/Report';
        directory = Directory(downloadsPath);

        // Create directory if it doesn't exist
        if (!await directory.exists()) {
          await directory.create(recursive: true);
          debugPrint(
              '[MeetingReportController] Created directory: $downloadsPath');
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create filename with date range
      final fileName =
          'Laporan_Rapat_${_formatDate(startDate.value)}_${_formatDate(endDate.value)}.pdf';
      final filePath = '${directory.path}/$fileName';

      debugPrint('[MeetingReportController] Saving to: $filePath');

      // Get token for authorization
      final token = _storage.getData<String>(StorageKey.token);

      // Download file
      await _apiProvider.downloadFile(
        APIEndpoint.meetingReportDownloadPdf,
        filePath,
        query: queryParams,
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
        onReceiveProgress: (received, total) {
          if (total != -1) {
            downloadProgress.value = received / total;
            debugPrint(
                '[MeetingReportController] Progress: ${(downloadProgress.value * 100).toStringAsFixed(0)}%');
          }
        },
      );

      debugPrint('[MeetingReportController] Download completed: $filePath');

      // Show success message
      _notif.showSuccess('Laporan berhasil diunduh');

      // Ask user if they want to open the file
      _showOpenFileDialog(filePath);
    } catch (e) {
      debugPrint('[MeetingReportController] Error downloading report: $e');
      _notif.showError('Gagal mengunduh laporan: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isDownloading.value = false;
      downloadProgress.value = 0.0;
    }
  }

  // Show bottom sheet to open file
  void _showOpenFileDialog(String filePath) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Success icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Colors.green.shade600,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            // Title
            const Text(
              'Unduhan Selesai',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // Message
            Text(
              'Laporan rapat berhasil diunduh.\nApakah Anda ingin membuka file sekarang?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Nanti',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.back();
                      _openFile(filePath);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Buka',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Open downloaded file
  Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        _notif.showError('Tidak dapat membuka file: ${result.message}');
      }
    } catch (e) {
      debugPrint('[MeetingReportController] Error opening file: $e');
      _notif.showError('Tidak dapat membuka file');
    }
  }

  // Select start date
  Future<void> selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Mulai',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      updateStartDate(picked);
    }
  }

  // Select end date
  Future<void> selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate.value,
      firstDate: startDate.value,
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Akhir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );

    if (picked != null) {
      updateEndDate(picked);
    }
  }
}
