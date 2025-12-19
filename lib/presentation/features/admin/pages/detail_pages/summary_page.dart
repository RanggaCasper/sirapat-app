import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';
import 'package:sirapat_app/presentation/features/admin/pages/edit_meeting_minute_page.dart';

class SummaryPage extends StatelessWidget {
  final int meetingId;

  const SummaryPage({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    // Ensure MeetingMinuteController is registered before accessing it.
    if (!Get.isRegistered<MeetingMinuteController>()) {
      MeetingMinuteBinding().dependencies();
    }

    final meetingMinuteController = Get.find<MeetingMinuteController>();

    return FutureBuilder<MeetingMinute?>(
      future: meetingMinuteController.getMeetingMinuteByMeetingId(meetingId),
      builder: (context, snapshot) {
        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get meeting minute data (may be null)
        final meetingMinute = snapshot.data;

        // Always display the notulensi layout (even if empty)
        return _buildMinutesTab(meetingMinute, meetingMinuteController);
      },
    );
  }

  Widget _buildMinutesTab(
    MeetingMinute? meetingMinute,
    MeetingMinuteController controller,
  ) {
    final summary = meetingMinute?.summary ?? '';
    final pembahasan = meetingMinute?.pembahasan ?? '';
    final keputusan = meetingMinute?.keputusan;
    final tindakan = meetingMinute?.tindakan;
    final anggaran = meetingMinute?.anggaran;
    final totalAnggaran = meetingMinute?.totalAnggaran ?? '';
    final catatanAnggaran = meetingMinute?.catatanAnggaran ?? '';
    final approvedBy = meetingMinute?.approvedBy;
    final approvedAt = meetingMinute?.approvedAt;
    final meetingMinuteId = meetingMinute?.id;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Approval Status
          if (approvedBy != null && approvedAt != null) ...[
            _buildApprovalSection(approvedBy, approvedAt),
            const SizedBox(height: 20),
          ] else ...[
            _buildPendingApprovalBadge(),
            const SizedBox(height: 20),
          ],

          // Action Buttons
          if (meetingMinuteId != null) ...[
            _buildActionButtons(
              meetingMinuteId,
              controller,
              meetingMinute,
              isApproved: approvedBy != null && approvedAt != null,
            ),
            const SizedBox(height: 20),
          ],

          // Summary
          _buildFormattedContentSection(
            title: 'Ringkasan Notulensi',
            content: summary,
            icon: Icons.summarize,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 16),

          // Pembahasan
          _buildFormattedContentSection(
            title: 'Pembahasan',
            content: pembahasan,
            icon: Icons.chat_bubble_outline,
            iconColor: Colors.blue,
          ),
          const SizedBox(height: 16),

          // Keputusan
          if (keputusan != null && keputusan.isNotEmpty) ...[
            _buildListSection(
              title: 'Keputusan',
              items: keputusan,
              icon: Icons.gavel,
              iconColor: Colors.green,
            ),
            const SizedBox(height: 16),
          ],

          // Tindakan
          if (tindakan != null && tindakan.isNotEmpty) ...[
            _buildListSection(
              title: 'Tindakan',
              items: tindakan,
              icon: Icons.assignment_turned_in,
              iconColor: Colors.orange,
            ),
            const SizedBox(height: 16),
          ],

          // Anggaran
          if (anggaran != null && anggaran.isNotEmpty) ...[
            _buildAnggaranSection(anggaran, totalAnggaran, catatanAnggaran),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildFormattedContentSection({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    // Split content by \n and render each line
    final lines = content.split('\\n');

    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: iconColor.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (content.isEmpty)
              Text(
                'Belum ada konten',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: lines.map((line) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      line,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalSection(dynamic approvedBy, DateTime? approvedAt) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notulen Telah Disetujui',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (approvedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Disetujui pada: ${_formatDateTime(approvedAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingApprovalBadge() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.pending, color: Colors.orange.shade700, size: 24),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Menunggu Persetujuan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(int meetingMinuteId,
      MeetingMinuteController controller, MeetingMinute? meetingMinute,
      {required bool isApproved}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_download, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Unduh & Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.previewPdf(meetingMinuteId),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Preview', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.downloadPdf(meetingMinuteId),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text('PDF', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.downloadWord(meetingMinuteId),
                  icon: const Icon(Icons.description, size: 18),
                  label: const Text('Word', style: TextStyle(fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Edit button - only show if NOT approved
          if (!isApproved) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(
                    () => EditMeetingMinutePage(
                      meetingMinuteId: meetingMinuteId,
                      meetingMinute: meetingMinute,
                    ),
                  );
                  // Refresh if data was updated
                  if (result == true) {
                    Get.forceAppUpdate();
                  }
                },
                icon: const Icon(Icons.edit, size: 18),
                label:
                    const Text('Edit Notulen', style: TextStyle(fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: iconColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${index + 1}. ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: iconColor,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAnggaranSection(
    List<Map<String, dynamic>> anggaran,
    String totalAnggaran,
    String catatanAnggaran,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.monetization_on, color: Colors.purple, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Anggaran',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (anggaran.isNotEmpty) ...[
            ...anggaran.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}. ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.purple,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Jumlah : ${item['budget'] ?? ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (totalAnggaran.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Total : $totalAnggaran',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
          if (catatanAnggaran.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan : $catatanAnggaran',
              style: const TextStyle(
                fontSize: 10,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
