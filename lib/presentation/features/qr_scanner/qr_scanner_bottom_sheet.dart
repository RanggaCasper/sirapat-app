import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/features/qr_scanner/pages/qr_scanner_page.dart';

/// Helper function to show QR Scanner as a bottom sheet
///
/// Usage:
/// ```dart
/// showQrScannerBottomSheet();
/// ```
Future<void> showQrScannerBottomSheet() async {
  await Get.bottomSheet(
    const QrScannerPage(),
    isScrollControlled: true,
    enableDrag: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    enterBottomSheetDuration: const Duration(milliseconds: 250),
    exitBottomSheetDuration: const Duration(milliseconds: 200),
  );
}
