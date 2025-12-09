import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/participant_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/domain/usecases/attendance/get_attendance_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  MobileScannerController cameraController = MobileScannerController();
  MeetingController meetingController = Get.find<MeetingController>();
  bool isScanning = true;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;
      if (code != null) {
        setState(() {
          isScanning = false;
        });
        _handleQrCode(code);
        break;
      }
    }
  }

  void _handleQrCode(String code) {
    cameraController.stop();

    Map<String, dynamic>? data;

    // Decode JSON
    try {
      data = jsonDecode(code);
    } catch (e) {
      data = null;
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BottomSheetHandle(margin: EdgeInsets.only(bottom: 16)),
            const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 64),
            const SizedBox(height: 16),

            Text(
              data != null ? "QR Code Terdeteksi" : "QR Tidak Valid",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // CONTENT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: data == null
                  ? const Text(
                      "Format QR tidak sesuai.\nPastikan QR berasal dari aplikasi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _qrItem("Judul Rapat", data["title"]),
                        _qrItem("Tanggal", data["date"]),
                        _qrItem("Mulai", data["startTime"]),
                        _qrItem("Selesai", data["endTime"]),
                        // _qrItem("Passcode", data["passcode"]),
                      ],
                    ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _resumeScanning();
                    },
                    child: const Text('Scan Lagi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: data == null
                        ? null
                        : () async {
                            final passcode = data!["passcode"].toString();

                            await meetingController.joinMeetingByCode(passcode);
                            Get.to(
                              () => DetailMeetPage(meetingId: data!["id"]),
                              binding: BindingsBuilder(() {
                                if (!Get.isRegistered<GetAttendanceUseCase>()) {
                                  MeetingBinding().dependencies();
                                  ParticipantBinding().dependencies();
                                  MeetingMinuteBinding().dependencies();
                                }
                              }),
                              transition: Transition.rightToLeft,
                              arguments: data["id"],
                            );
                          },
                    child: const Text('Gunakan'),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
          ],
        ),
      ),
      isDismissible: false,
    );
  }

  Widget _qrItem(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value?.toString() ?? "-",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  void _resumeScanning() {
    setState(() {
      isScanning = true;
    });
    cameraController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: cameraController, onDetect: _onDetect),
          _buildScannerOverlay(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        Expanded(child: Container(color: Colors.black54)),
        SizedBox(
          height: 300,
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.black54)),
              Container(
                width: 300,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner decorations
                    Positioned(
                      top: 0,
                      left: 0,
                      child: _buildCorner(true, true),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _buildCorner(true, false),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: _buildCorner(false, true),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCorner(false, false),
                    ),
                  ],
                ),
              ),
              Expanded(child: Container(color: Colors.black54)),
            ],
          ),
        ),
        Expanded(
          child: Container(
            color: Colors.black54,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Arahkan kamera ke kode QR',
                  style: AppTextStyles.body.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(bool isTop, bool isLeft) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          left: isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          bottom: !isTop
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
          right: !isLeft
              ? BorderSide(color: AppColors.primary, width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
