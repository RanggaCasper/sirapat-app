import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/participant_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/domain/usecases/attendance/get_attendance_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return "-";
    try {
      // Remove seconds if present (HH:mm:ss -> HH:mm)
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  Future<void> _pickImageAndScan() async {
    try {
      // Hanya izinkan pilih dari galeri, BUKAN dari kamera
      // Untuk menghindari Android menyimpan foto baru ke Pictures
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
        allowMultiple: false,
        withData: false, // Jangan load data ke memory
        withReadStream: false, // Jangan buat stream
        allowCompression:
            false, // Jangan compress (hindari pembuatan file baru)
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;

        // Analyze the image file
        final barcodes = await cameraController.analyzeImage(path);

        if (barcodes != null && barcodes.barcodes.isNotEmpty) {
          final code = barcodes.barcodes.first.rawValue;
          if (code != null) {
            setState(() {
              isScanning = false;
            });
            _handleQrCode(code);
          } else {
            _showError('QR code tidak dapat dibaca dari gambar');
          }
        } else {
          _showError('Tidak ada QR code yang ditemukan dalam gambar');
        }

        // Bersihkan cache file picker setelah selesai
        try {
          await FilePicker.platform.clearTemporaryFiles();
        } catch (e) {
          debugPrint('Failed to clear temporary files: $e');
        }
      }
    } catch (e) {
      _showError('Gagal membaca gambar: ${e.toString()}');
    }
  }

  void _showError(String message) {
    final notif = Get.find<NotificationController>();
    notif.showError(message);
    _resumeScanning();
  }

  void _handleQrCode(String code) {
    cameraController.stop();

    Map<String, dynamic>? data;

    // Decode JSON
    try {
      debugPrint('[QR Scanner] Raw QR code data: $code');
      data = jsonDecode(code);
      debugPrint('[QR Scanner] Decoded data: $data');
    } catch (e) {
      debugPrint('[QR Scanner] Error decoding JSON: $e');
      data = null;
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetHandle(margin: EdgeInsets.only(bottom: 16)),
              const Icon(Icons.qr_code_scanner, color: Colors.blue, size: 64),
              const SizedBox(height: 12),

              Text(
                data != null ? "QR Code Terdeteksi" : "QR Tidak Valid",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

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
                          _qrItem("Tanggal", _formatDate(data["date"])),
                          _qrItem("Mulai", _formatTime(data["startTime"])),
                          _qrItem("Selesai", _formatTime(data["endTime"])),
                          // _qrItem("Passcode", data["passcode"]),
                        ],
                      ),
              ),

              const SizedBox(height: 20),

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
                              final meetingId = data["id"] as int;

                              await meetingController.joinMeetingByCode(
                                passcode,
                              );

                              // Clear previous selected meeting to avoid conflicts
                              meetingController.selectedMeeting.value = null;

                              Get.to(
                                () => DetailMeetPage(meetingId: meetingId),
                                binding: BindingsBuilder(() {
                                  if (!Get.isRegistered<
                                      GetAttendanceUseCase>()) {
                                    MeetingBinding().dependencies();
                                    ParticipantBinding().dependencies();
                                    MeetingMinuteBinding().dependencies();
                                  }
                                }),
                                transition: Transition.rightToLeft,
                              );
                            },
                      child: const Text('Gunakan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                const BottomSheetHandle(
                  color: Colors.white,
                  margin: EdgeInsets.only(bottom: 12),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'Scan QR Code',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Arahkan kamera ke QR code',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        onSelected: (value) {
                          if (value == 'gallery') {
                            _pickImageAndScan();
                          } else if (value == 'flash') {
                            cameraController.toggleTorch();
                          } else if (value == 'switch') {
                            cameraController.switchCamera();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'gallery',
                            child: Row(
                              children: [
                                Icon(Icons.photo_library),
                                SizedBox(width: 12),
                                Text('Pilih dari Galeri'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'flash',
                            child: Row(
                              children: [
                                Icon(Icons.flash_on),
                                SizedBox(width: 12),
                                Text('Nyalakan/Matikan Flash'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'switch',
                            child: Row(
                              children: [
                                Icon(Icons.flip_camera_android),
                                SizedBox(width: 12),
                                Text('Ganti Kamera'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Scanner Body
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                _buildScannerOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      children: [
        Expanded(child: Container(color: Colors.black54)),
        SizedBox(
          height: 250,
          child: Row(
            children: [
              Expanded(child: Container(color: Colors.black54)),
              Container(
                width: 250,
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white.withOpacity(0.7),
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Posisikan QR code di dalam kotak',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Atau pilih gambar dari galeri',
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
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
