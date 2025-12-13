import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class QrDownloadHelper {
  /// Download QR code to Download/Sirapat folder
  /// Returns the file path if successful, null otherwise
  static Future<String?> downloadQrCode({
    required GlobalKey repaintBoundaryKey,
    required String fileName,
  }) async {
    try {
      // Request storage permission for Android 13+
      if (Platform.isAndroid) {
        final bool hasPermission = await _requestStoragePermission();
        if (!hasPermission) {
          final String error =
              'Permission ditolak. Berikan izin penyimpanan di Settings > Apps > SiRapat > Permissions';
          debugPrint('[QrDownloadHelper] $error');
          throw Exception(error);
        }
      }

      // Capture QR code as image
      final Uint8List? imageBytes = await _captureQrCode(repaintBoundaryKey);
      if (imageBytes == null) {
        final String error = 'Gagal mengambil gambar QR code. Coba lagi.';
        debugPrint('[QrDownloadHelper] $error');
        throw Exception(error);
      }

      // Get Download/Sirapat directory
      final Directory? directory = await _getDownloadDirectory();
      if (directory == null) {
        final String error =
            'Tidak dapat mengakses folder Download. Periksa izin penyimpanan.';
        debugPrint('[QrDownloadHelper] $error');
        throw Exception(error);
      }

      // Create Sirapat subfolder if not exists
      final Directory sirapatFolder = Directory('${directory.path}/Sirapat');
      if (!await sirapatFolder.exists()) {
        await sirapatFolder.create(recursive: true);
        debugPrint(
          '[QrDownloadHelper] Created Sirapat folder: ${sirapatFolder.path}',
        );
      }

      // Sanitize filename (remove special characters)
      final String sanitizedFileName = fileName
          .replaceAll(RegExp(r'[^\w\s-]'), '')
          .replaceAll(RegExp(r'\s+'), '_');

      // Create full file path
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fullFileName = '${sanitizedFileName}_$timestamp.png';
      final String filePath = '${sirapatFolder.path}/$fullFileName';

      // Save file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      debugPrint('[QrDownloadHelper] QR code saved to: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('[QrDownloadHelper] Error downloading QR code: $e');
      rethrow; // Propagate error with details
    }
  }

  /// Request storage permission for Android 13+
  static Future<bool> _requestStoragePermission() async {
    try {
      // For Android 13+ (API 33+), use photos permission
      if (await Permission.photos.isGranted) {
        return true;
      }

      // Request permission
      final status = await Permission.photos.request();

      if (status.isGranted) {
        return true;
      }

      // If photos permission denied, try storage permission for older Android
      if (await Permission.storage.isGranted) {
        return true;
      }

      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } catch (e) {
      debugPrint('[QrDownloadHelper] Error requesting permission: $e');
      // On older Android versions, storage permission might not be needed
      return true;
    }
  }

  /// Get the appropriate download directory based on platform
  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try primary download folder first
        Directory directory = Directory('/storage/emulated/0/Download');
        if (await directory.exists()) {
          return directory;
        }

        // Fallback to external storage
        directory = (await getExternalStorageDirectory())!;
        return directory;
      } else if (Platform.isIOS) {
        return await getApplicationDocumentsDirectory();
      } else {
        return await getDownloadsDirectory();
      }
    } catch (e) {
      debugPrint('[QrDownloadHelper] Error getting download directory: $e');
      return null;
    }
  }

  /// Capture widget as image from RepaintBoundary
  static Future<Uint8List?> _captureQrCode(GlobalKey key) async {
    Uint8List? result;
    
    try {
      // Wait for the widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 300));

      final context = key.currentContext;
      if (context == null) {
        debugPrint('[QrDownloadHelper] Context is null');
        return null;
      }

      // Check if context is still mounted after async gap
      if (!context.mounted) {
        debugPrint('[QrDownloadHelper] Context no longer mounted');
        return null;
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[QrDownloadHelper] Boundary is null');
        return null;
      }

      // Check if the boundary needs paint (only in debug mode)
      assert(() {
        if (boundary.debugNeedsPaint) {
          debugPrint('[QrDownloadHelper] Boundary needs paint in debug mode');
        }
        return true;
      }());

      // Additional wait to ensure rendering is complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture the image with error handling
      final ui.Image? image = await boundary.toImage(pixelRatio: 3.0);
      if (image == null) {
        debugPrint('[QrDownloadHelper] Failed to capture image');
        return null;
      }

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('[QrDownloadHelper] Failed to convert image to byte data');
        return null;
      }

      result = byteData.buffer.asUint8List();
      debugPrint(
        '[QrDownloadHelper] Successfully captured QR code: ${result.length} bytes',
      );
      return result;
    } catch (e, stackTrace) {
      debugPrint('[QrDownloadHelper] Error capturing QR code: $e');
      debugPrint('[QrDownloadHelper] Stack trace: $stackTrace');
      return null;
    }
  }
}
