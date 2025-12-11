import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';

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
        final minutes = meetingMinute?.minutes ?? '';

        // Get keputusan from elements instead of decisions
        final keputusan = meetingMinute?.elements?['keputusan'] as List?;

        final approvedBy = meetingMinute?.approvedBy;
        final approvedAt = meetingMinute?.approvedAt;

        // Always display the notulensi layout (even if empty)
        return _buildMinutesTab(minutes, keputusan, approvedBy, approvedAt);
      },
    );
  }

  Widget _buildMinutesTab(
    String minutes,
    List? keputusan,
    dynamic approvedBy,
    DateTime? approvedAt,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFormattedContentSection(
            title: 'Notulensi Rapat',
            content: minutes,
            icon: Icons.description,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: 20),
          if (approvedBy != null && approvedAt != null) ...[
            _buildApprovalSection(approvedBy, approvedAt),
          ] else ...[
            _buildPendingApprovalBadge(),
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
