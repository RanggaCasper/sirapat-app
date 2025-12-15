import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/get_meeting_minute_by_meeting_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/approve_meeting_minute_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting_minute/update_meeting_minute_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/app/services/local_storage.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:permission_handler/permission_handler.dart';

class MeetingMinuteController extends GetxController {
  final GetMeetingMinuteByMeetingIdUseCase _getMeetingMinuteByMeetingId;
  final ApproveMeetingMinuteUseCase _approveMeetingMinute;
  final UpdateMeetingMinuteUseCase _updateMeetingMinute;
  Dio? _dioInstance;

  MeetingMinuteController(
    this._getMeetingMinuteByMeetingId,
    this._approveMeetingMinute,
    this._updateMeetingMinute,
  );

  /// Lazy getter for Dio instance with auth headers
  Dio get _dio {
    if (_dioInstance == null) {
      _dioInstance = Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ));

      // Add interceptor to add auth token
      _dioInstance!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            try {
              final storage = Get.find<LocalStorageService>();
              final token = storage.getData<String>(StorageKey.token);

              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              debugPrint('[Dio] Request to: ${options.uri}');
              debugPrint('[Dio] Token exists: ${token != null}');
              return handler.next(options);
            } catch (e) {
              debugPrint('[Dio] Error adding auth header: $e');
              return handler.next(options);
            }
          },
          onError: (error, handler) {
            debugPrint(
                '[Dio] Error: ${error.response?.statusCode} - ${error.message}');
            debugPrint('[Dio] Error response: ${error.response?.data}');
            return handler.next(error);
          },
        ),
      );
    }
    return _dioInstance!;
  }

  // Observables
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  final RxString _errorMessage = ''.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;

  NotificationController get _notif => Get.find<NotificationController>();

  dynamic get decisions => null;

  dynamic get content => null;

  /// Helper method to get downloads directory path
  Future<String> _getDownloadsDirectory() async {
    Directory? directory;

    try {
      if (Platform.isAndroid) {
        // Request storage permission
        if (await Permission.storage.request().isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          directory = Directory('/storage/emulated/0/Download/sirapat/minutes');
        } else {
          // Fallback to app directory if permission denied
          final appDir = await getApplicationDocumentsDirectory();
          directory = Directory('${appDir.path}/sirapat/minutes');
        }
      } else {
        // For iOS and other platforms
        final appDir = await getApplicationDocumentsDirectory();
        directory = Directory('${appDir.path}/sirapat/minutes');
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        debugPrint(
            '[MeetingMinuteController] Created directory: ${directory.path}');
      }

      return directory.path;
    } catch (e) {
      debugPrint(
          '[MeetingMinuteController] Error getting downloads directory: $e');
      // Fallback to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final fallbackDir = Directory('${appDir.path}/sirapat/minutes');
      if (!await fallbackDir.exists()) {
        await fallbackDir.create(recursive: true);
      }
      return fallbackDir.path;
    }
  }

  /// Helper method to get user-friendly error message
  String _getUserFriendlyErrorMessage(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (statusCode) {
      case 400:
        return 'Data tidak valid. Silakan coba lagi.';
      case 401:
        return 'Sesi Anda telah berakhir. Silakan login kembali.';
      case 403:
        return 'Anda tidak memiliki akses untuk melakukan ini.';
      case 404:
        return 'File tidak ditemukan. Notulen mungkin belum tersedia.';
      case 405:
        return 'Fitur download belum tersedia di server. Hubungi administrator.';
      case 500:
        return 'Server mengalami gangguan. Silakan coba lagi nanti.';
      case 503:
        return 'Server sedang maintenance. Silakan coba lagi nanti.';
      default:
        if (error.type == DioExceptionType.connectionTimeout) {
          return 'Koneksi timeout. Periksa koneksi internet Anda.';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          return 'Download terlalu lama. Silakan coba lagi.';
        } else if (error.type == DioExceptionType.unknown) {
          return 'Tidak ada koneksi internet.';
        }
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  Future<MeetingMinute?> getMeetingMinuteByMeetingId(int id) async {
    try {
      final data = await _getMeetingMinuteByMeetingId.execute(id);
      
      return data;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingMinuteController] ApiException in getMeetingMinuteByMeetingId: ${e.message}',
      );

      final message = e.message.toLowerCase();

      if (message.contains('no meeting minute found') ||
          message.contains('not found') ||
          message.contains('tidak ditemukan')) {
        return null;
      }

      _notif.showError(e.message);

      return null;
    } catch (e) {
      debugPrint(
        '[MeetingMinuteController] Exception in getMeetingMinuteByMeetingId: $e',
      );
      _notif.showError(e.toString());
      return null;
    }
  }

  /// Approve meeting minute
  Future<bool> approveMeetingMinute(int meetingMinuteId) async {
    try {
      isLoadingActionObs.value = true;

      debugPrint(
        '[MeetingMinuteController] Approving meeting minute with ID: $meetingMinuteId',
      );

      // Call use case to approve meeting minute
      await _approveMeetingMinute.execute(meetingMinuteId);

      isLoadingActionObs.value = false;

      debugPrint(
        '[MeetingMinuteController] Meeting minute approved successfully',
      );

      _notif.showSuccess('Notulen rapat berhasil disetujui');
      return true;
    } on ApiException catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] ApiException in approveMeetingMinute: ${e.message}',
      );
      _notif.showError(e.message);
      return false;
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] Exception in approveMeetingMinute: $e',
      );
      _notif.showError('Gagal menyetujui notulen: ${e.toString()}');
      return false;
    }
  }

  /// Update meeting minute (admin only)
  Future<MeetingMinute?> updateMeetingMinute({
    required int meetingMinuteId,
    String? originalText,
    String? summary,
    String? pembahasan,
    List<String>? keputusan,
    List<String>? tindakan,
    List<Map<String, dynamic>>? anggaran,
    String? totalAnggaran,
    String? catatanAnggaran,
  }) async {
    try {
      isLoadingActionObs.value = true;

      debugPrint(
        '[MeetingMinuteController] Updating meeting minute with ID: $meetingMinuteId',
      );

      // Call use case to update meeting minute
      final updatedMinute = await _updateMeetingMinute.execute(
        meetingMinuteId: meetingMinuteId,
        originalText: originalText,
        summary: summary,
        pembahasan: pembahasan,
        keputusan: keputusan,
        tindakan: tindakan,
        anggaran: anggaran,
        totalAnggaran: totalAnggaran,
        catatanAnggaran: catatanAnggaran,
      );

      isLoadingActionObs.value = false;

      debugPrint(
        '[MeetingMinuteController] Meeting minute updated successfully',
      );

      _notif.showSuccess('Notulen rapat berhasil diperbarui');
      return updatedMinute;
    } on ApiException catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] ApiException in updateMeetingMinute: ${e.message}',
      );
      _notif.showError(e.message);
      return null;
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint(
        '[MeetingMinuteController] Exception in updateMeetingMinute: $e',
      );
      _notif.showError('Gagal memperbarui notulen: ${e.toString()}');
      return null;
    }
  }

  /// Preview PDF - Download and open with default PDF viewer
  Future<void> previewPdf(int meetingMinuteId) async {
    try {
      isLoadingActionObs.value = true;
      _notif.showInfo('Mengunduh preview PDF...');

      final url =
          '${AppConstants.baseUrl}/api/${AppConstants.apiVersion}/admin/meeting-minute/$meetingMinuteId/preview-pdf';
      debugPrint('[MeetingMinuteController] Opening preview PDF: $url');

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/meeting_minute_$meetingMinuteId.pdf';

      // Download file
      try {
        await _dio.download(url, filePath);
        debugPrint('[MeetingMinuteController] PDF downloaded to: $filePath');

        isLoadingActionObs.value = false;

        // Open file with default viewer
        final result = await OpenFilex.open(filePath);
        if (result.type != ResultType.done) {
          _notif.showError('Gagal membuka PDF: ${result.message}');
        }
      } on DioException catch (dioError) {
        final statusCode = dioError.response?.statusCode;
        debugPrint(
            '[MeetingMinuteController] DioException: ${dioError.message}');
        debugPrint('[MeetingMinuteController] Status code: $statusCode');
        debugPrint(
            '[MeetingMinuteController] Response data: ${dioError.response?.data}');

        isLoadingActionObs.value = false;
        final errorMessage = _getUserFriendlyErrorMessage(dioError);
        _notif.showError(errorMessage);

        // Additional info for 405 error
        if (statusCode == 405) {
          debugPrint(
              '[MeetingMinuteController] Endpoint mungkin salah atau metode tidak didukung');
        }
      }
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint('[MeetingMinuteController] Error previewing PDF: $e');
      _notif.showError('Gagal membuka preview PDF. Silakan coba lagi.');
    }
  }

  /// Download PDF - Save to downloads/sirapat/minutes/ directory
  Future<void> downloadPdf(int meetingMinuteId) async {
    try {
      isLoadingActionObs.value = true;
      _notif.showInfo('Memulai unduhan PDF...');

      final url =
          '${AppConstants.baseUrl}/api/${AppConstants.apiVersion}/admin/meeting-minute/$meetingMinuteId/download-pdf';
      debugPrint('[MeetingMinuteController] Downloading PDF: $url');

      // Get downloads/sirapat/minutes directory
      final downloadsPath = await _getDownloadsDirectory();
      final fileName = 'notulen_$meetingMinuteId.pdf';
      final filePath = '$downloadsPath/$fileName';

      try {
        // Download file with progress
        await _dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              _notif.showInfo('Mengunduh PDF... $progress%');
              debugPrint(
                  '[MeetingMinuteController] Download progress: $progress%');
            }
          },
        );
        debugPrint('[MeetingMinuteController] PDF downloaded to: $filePath');

        isLoadingActionObs.value = false;
        _notif.showSuccess(
            'PDF berhasil diunduh!\nLokasi: Download/sirapat/minutes/$fileName');
      } on DioException catch (dioError) {
        final statusCode = dioError.response?.statusCode;
        debugPrint(
            '[MeetingMinuteController] DioException: ${dioError.message}');
        debugPrint('[MeetingMinuteController] Status code: $statusCode');
        debugPrint(
            '[MeetingMinuteController] Response data: ${dioError.response?.data}');

        isLoadingActionObs.value = false;
        final errorMessage = _getUserFriendlyErrorMessage(dioError);
        _notif.showError(errorMessage);
      }
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint('[MeetingMinuteController] Error downloading PDF: $e');
      _notif.showError('Gagal mengunduh PDF. Silakan coba lagi.');
    }
  }

  /// Download Word - Save to downloads/sirapat/minutes/ directory
  Future<void> downloadWord(int meetingMinuteId) async {
    try {
      isLoadingActionObs.value = true;
      _notif.showInfo('Memulai unduhan Word...');

      final url =
          '${AppConstants.baseUrl}/api/${AppConstants.apiVersion}/admin/meeting-minute/$meetingMinuteId/download-word';
      debugPrint('[MeetingMinuteController] Downloading Word: $url');

      // Get downloads/sirapat/minutes directory
      final downloadsPath = await _getDownloadsDirectory();
      final fileName = 'notulen_$meetingMinuteId.docx';
      final filePath = '$downloadsPath/$fileName';

      try {
        // Download file with progress
        await _dio.download(
          url,
          filePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              _notif.showInfo('Mengunduh Word... $progress%');
              debugPrint(
                  '[MeetingMinuteController] Download progress: $progress%');
            }
          },
        );
        debugPrint(
            '[MeetingMinuteController] Word document downloaded to: $filePath');

        isLoadingActionObs.value = false;
        _notif.showSuccess(
            'Word berhasil diunduh!\nLokasi: Download/sirapat/minutes/$fileName');
      } on DioException catch (dioError) {
        final statusCode = dioError.response?.statusCode;
        debugPrint(
            '[MeetingMinuteController] DioException: ${dioError.message}');
        debugPrint('[MeetingMinuteController] Status code: $statusCode');
        debugPrint(
            '[MeetingMinuteController] Response data: ${dioError.response?.data}');

        isLoadingActionObs.value = false;
        final errorMessage = _getUserFriendlyErrorMessage(dioError);
        _notif.showError(errorMessage);
      }
    } catch (e) {
      isLoadingActionObs.value = false;
      debugPrint('[MeetingMinuteController] Error downloading Word: $e');
      _notif.showError('Gagal mengunduh Word. Silakan coba lagi.');
    }
  }
}
