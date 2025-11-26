import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class PasscodeQrBottomSheet extends StatefulWidget {
  final String passcode;
  final String meetingTitle;
  final String? meetingUuid;

  const PasscodeQrBottomSheet({
    Key? key,
    required this.passcode,
    required this.meetingTitle,
    this.meetingUuid,
  }) : super(key: key);

  @override
  State<PasscodeQrBottomSheet> createState() => _PasscodeQrBottomSheetState();
}

class _PasscodeQrBottomSheetState extends State<PasscodeQrBottomSheet> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isProcessing = false;

  NotificationController get _notif => Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            _buildHandle(),
            const SizedBox(height: AppSpacing.md),
            _buildHeader(),
            const SizedBox(height: AppSpacing.lg),
            _buildQrCode(),
            const SizedBox(height: AppSpacing.lg),
            _buildActionButtons(),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        children: [
          Icon(Icons.check_circle, size: 48, color: AppColors.success),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Rapat Berhasil Dibuat!',
            style: AppTextStyles.title.copyWith(fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            widget.meetingTitle,
            style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQrCode() {
    return RepaintBoundary(
      key: _qrKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: widget.passcode,
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        embeddedImage: const AssetImage('assets/logo.png'),
                        embeddedImageStyle: const QrEmbeddedImageStyle(
                          size: Size(40, 40),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Scan QR Code',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _isProcessing ? null : _downloadQrCode,
          icon: _isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.cardBackground,
                    ),
                  ),
                )
              : Icon(Icons.download, color: AppColors.cardBackground),
          label: Text(
            _isProcessing ? 'Menyimpan...' : 'Simpan',
            style: TextStyle(
              color: AppColors.cardBackground,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Future<Uint8List?> _captureQrCode() async {
    try {
      final RenderRepaintBoundary boundary =
          _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[PasscodeQrBottomSheet] Error capturing QR code: $e');
      return null;
    }
  }

  Future<void> _downloadQrCode() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final Uint8List? imageBytes = await _captureQrCode();
      if (imageBytes == null) {
        _notif.showError('Gagal membuat QR code');
        return;
      }

      // Get the downloads directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = await getDownloadsDirectory();
      }

      if (directory == null) {
        _notif.showError('Tidak dapat mengakses folder download');
        return;
      }

      // Create filename
      final String fileName =
          'sirapat_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Save file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      _notif.showSuccess('QR code berhasil disimpan di folder Download');
    } catch (e) {
      debugPrint('[PasscodeQrBottomSheet] Error downloading QR code: $e');
      _notif.showError('Gagal menyimpan QR code: ${e.toString()}');
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}

// Helper function to show the bottom sheet
void showPasscodeQrBottomSheet({
  required String passcode,
  required String meetingTitle,
  String? meetingUuid,
}) {
  Get.bottomSheet(
    PasscodeQrBottomSheet(
      passcode: passcode,
      meetingTitle: meetingTitle,
      meetingUuid: meetingUuid,
    ),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
  );
}
