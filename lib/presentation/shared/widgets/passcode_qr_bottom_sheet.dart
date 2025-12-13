import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/qr_download_helper.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class PasscodeQrBottomSheet extends StatefulWidget {
  final int meetingId;
  final String passcode;
  final String meetingTitle;
  final String meetingDate;
  final String meetingStartTime;
  final String meetingEndTime;
  final String? meetingUuid;

  const PasscodeQrBottomSheet({
    super.key,
    required this.meetingId,
    required this.passcode,
    required this.meetingTitle,
    required this.meetingDate,
    required this.meetingStartTime,
    required this.meetingEndTime,
    this.meetingUuid,
  });

  @override
  State<PasscodeQrBottomSheet> createState() => _PasscodeQrBottomSheetState();
}

class _PasscodeQrBottomSheetState extends State<PasscodeQrBottomSheet> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isProcessing = false;
  String? decryptedPasscode;
  bool _isLoading = true;

  NotificationController get _notif => Get.find<NotificationController>();

  @override
  void initState() {
    super.initState();
    _loadPasscode();
  }

  Future<void> _loadPasscode() async {
    final controller = Get.find<MeetingController>();
    final code = await controller.getMeetingPasscodeById(widget.meetingId);

    if (mounted) {
      setState(() {
        decryptedPasscode = code;
        _isLoading = false;
      });
    }
  }

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
        child: _isLoading
            ? const Padding(
                padding: EdgeInsets.all(48.0),
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  BottomSheetHandle(
                    color: AppColors.secondary.withOpacity(0.3),
                  ),
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
                      child: Builder(
                        builder: (context) {
                          final qrData = jsonEncode({
                            'id': widget.meetingId,
                            'title': widget.meetingTitle,
                            'date': widget.meetingDate,
                            'startTime': widget.meetingStartTime,
                            'endTime': widget.meetingEndTime,
                            'passcode': decryptedPasscode,
                          });
                          debugPrint(
                            '[PasscodeQrBottomSheet] QR data: $qrData',
                          );
                          return QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: 200,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            embeddedImage: const AssetImage('assets/logo.png'),
                            embeddedImageStyle: const QrEmbeddedImageStyle(
                              size: Size(40, 40),
                            ),
                          );
                        },
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

  Future<void> _downloadQrCode() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      final String? filePath = await QrDownloadHelper.downloadQrCode(
        repaintBoundaryKey: _qrKey,
        fileName: 'qr_${widget.meetingTitle}',
      );

      if (filePath != null) {
        _notif.showSuccess(
          'QR code berhasil disimpan di folder Download/Sirapat',
        );
      }
    } catch (e) {
      debugPrint('[PasscodeQrBottomSheet] Error downloading QR code: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      _notif.showError(errorMsg);
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}

// Helper function to show the bottom sheet
void showPasscodeQrBottomSheet({
  required int meetingId,
  required String passcode,
  required String meetingTitle,
  required String meetingDate,
  required String meetingStartTime,
  required String meetingEndTime,
  String? meetingUuid,
}) {
  Get.bottomSheet(
    PasscodeQrBottomSheet(
      meetingId: meetingId,
      passcode: passcode,
      meetingTitle: meetingTitle,
      meetingDate: meetingDate,
      meetingStartTime: meetingStartTime,
      meetingEndTime: meetingEndTime,
      meetingUuid: meetingUuid,
    ),
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
  );
}
