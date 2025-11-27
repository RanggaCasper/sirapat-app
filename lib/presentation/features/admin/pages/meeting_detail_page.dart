import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/qr_download_helper.dart';
import 'package:sirapat_app/app/util/date_formatter.dart';
import 'package:sirapat_app/app/util/status_chip_builder.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class MeetingDetailPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailPage({Key? key, required this.meeting}) : super(key: key);

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage> {
  final GlobalKey _qrKey = GlobalKey();
  bool _isDownloading = false;

  NotificationController get _notif => Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Detail Rapat'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingXL,
              decoration: BoxDecoration(color: AppColors.primary),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meeting.title,
                    style: AppTextStyles.heading2.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  StatusChipBuilder.buildMeetingStatusChip(
                    widget.meeting.status,
                  ),
                ],
              ),
            ),

            // QR Code Section (if available)
            if (widget.meeting.passcode != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildQrCodeSection(),
            ],

            // Meeting Details Section
            const SizedBox(height: AppSpacing.xl),
            _buildDetailsSection(),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Column(
        children: [
          Container(
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
                  // Background pattern
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.08,
                      child: Image.asset(
                        'assets/pattern.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          'QR Code Rapat',
                          style: AppTextStyles.title.copyWith(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        RepaintBoundary(
                          key: _qrKey,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: QrImageView(
                              data: widget.meeting.passcode!,
                              version: QrVersions.auto,
                              size: 300,
                              backgroundColor: Colors.white,
                              errorCorrectionLevel: QrErrorCorrectLevel.H,
                              embeddedImage: const AssetImage(
                                'assets/logo.png',
                              ),
                              embeddedImageStyle: const QrEmbeddedImageStyle(
                                size: Size(80, 80),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadQrCode,
              icon: _isDownloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.download, color: Colors.white),
              label: Text(
                _isDownloading ? 'Mengunduh...' : 'Simpan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: AppSpacing.paddingLG,
              child: Text(
                'Informasi Rapat',
                style: AppTextStyles.title.copyWith(fontSize: 18),
              ),
            ),
            const Divider(height: 1),
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Tanggal',
              value: DateFormatter.formatStringToLongDate(widget.meeting.date),
            ),
            const Divider(height: 1, indent: 56),
            _buildDetailRow(
              icon: Icons.access_time,
              label: 'Waktu',
              value: '${widget.meeting.startTime} - ${widget.meeting.endTime}',
            ),
            if (widget.meeting.location != null) ...[
              const Divider(height: 1, indent: 56),
              _buildDetailRow(
                icon: Icons.location_on,
                label: 'Lokasi',
                value: widget.meeting.location!,
              ),
            ],
            if (widget.meeting.description != null) ...[
              const Divider(height: 1, indent: 56),
              _buildDetailRow(
                icon: Icons.description,
                label: 'Deskripsi',
                value: widget.meeting.description!,
                isMultiline: true,
              ),
            ],
            if (widget.meeting.agenda != null) ...[
              const Divider(height: 1, indent: 56),
              _buildDetailRow(
                icon: Icons.list_alt,
                label: 'Agenda',
                value: widget.meeting.agenda!,
                isMultiline: true,
              ),
            ],
            if (widget.meeting.uuid != null) ...[
              const Divider(height: 1, indent: 56),
              _buildDetailRow(
                icon: Icons.fingerprint,
                label: 'UUID',
                value: widget.meeting.uuid!,
                isMultiline: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Row(
        crossAxisAlignment: isMultiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.secondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadQrCode() async {
    if (_isDownloading || widget.meeting.passcode == null) return;

    setState(() => _isDownloading = true);

    try {
      final String? filePath = await QrDownloadHelper.downloadQrCode(
        repaintBoundaryKey: _qrKey,
        fileName: 'qr_${widget.meeting.title}',
      );

      if (filePath == null) {
        _notif.showError('Gagal menyimpan QR code');
        return;
      }

      _notif.showSuccess(
        'QR code berhasil disimpan di folder Download/Sirapat',
      );
    } catch (e) {
      debugPrint('[MeetingDetailPage] Error downloading QR code: $e');
      _notif.showError('Gagal menyimpan QR code: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
}
