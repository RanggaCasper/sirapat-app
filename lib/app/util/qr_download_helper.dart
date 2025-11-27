import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class QrDownloadHelper {
  /// Download QR code to Download/Sirapat folder
  /// Returns the file path if successful, null otherwise
  static Future<String?> downloadQrCode({
    required GlobalKey repaintBoundaryKey,
    required String fileName,
  }) async {
    try {
      // Capture QR code as image
      final Uint8List? imageBytes = await _captureQrCode(repaintBoundaryKey);
      if (imageBytes == null) {
        debugPrint('[QrDownloadHelper] Failed to capture QR code');
        return null;
      }

      // Get Download/Sirapat directory
      final Directory? directory = await _getDownloadDirectory();
      if (directory == null) {
        debugPrint('[QrDownloadHelper] Failed to get download directory');
        return null;
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
      return null;
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
    try {
      // Wait for the widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final context = key.currentContext;
      if (context == null) {
        debugPrint('[QrDownloadHelper] Context is null');
        return null;
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[QrDownloadHelper] Boundary is null');
        return null;
      }

      // Check if the boundary needs paint
      if (boundary.debugNeedsPaint) {
        debugPrint('[QrDownloadHelper] Boundary needs paint, waiting...');
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[QrDownloadHelper] Error capturing QR code: $e');
      return null;
    }
  }
}
