import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:intl/intl.dart';

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
                  _buildStatusChip(widget.meeting.status),
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

  Widget _buildStatusChip(String status) {
    Color chipColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'scheduled':
        chipColor = AppColors.success;
        statusText = 'Terjadwal';
        break;
      case 'ongoing':
        chipColor = AppColors.warning;
        statusText = 'Berlangsung';
        break;
      case 'completed':
        chipColor = AppColors.success;
        statusText = 'Selesai';
        break;
      case 'cancelled':
        chipColor = AppColors.error;
        statusText = 'Dibatalkan';
        break;
      default:
        chipColor = AppColors.accent;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withOpacity(0.3)),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQrCodeSection() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: RepaintBoundary(
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
                // Background pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset('assets/pattern.png', fit: BoxFit.cover),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'QR Code Rapat',
                        style: AppTextStyles.title.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: QrImageView(
                          data: widget.meeting.passcode!,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
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
                ),
              ],
            ),
          ),
        ),
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
              value: _formatDate(widget.meeting.date),
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

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dateTime);
    } catch (e) {
      return date;
    }
  }

  Future<Uint8List?> _captureQrCode() async {
    try {
      // Wait for the widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final context = _qrKey.currentContext;
      if (context == null) {
        debugPrint('[MeetingDetailPage] Context is null');
        return null;
      }

      final boundary = context.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        debugPrint('[MeetingDetailPage] Boundary is null');
        return null;
      }

      // Check if the boundary needs paint
      if (boundary.debugNeedsPaint) {
        debugPrint('[MeetingDetailPage] Boundary needs paint, waiting...');
        await Future.delayed(const Duration(milliseconds: 200));
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('[MeetingDetailPage] Error capturing QR code: $e');
      return null;
    }
  }

  Future<void> _downloadQrCode() async {
    if (_isDownloading || widget.meeting.passcode == null) return;

    setState(() => _isDownloading = true);

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
          'qr_code_${widget.meeting.title.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${directory.path}/$fileName';

      // Save file
      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);

      _notif.showSuccess('QR code berhasil disimpan di folder Download');
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
