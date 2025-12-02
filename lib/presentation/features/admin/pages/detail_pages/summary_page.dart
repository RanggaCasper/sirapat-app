import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class SummaryPage extends GetView<MeetingController> {
  final int? meetingId;

  const SummaryPage({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    // Fetch meeting data when arguments are available
    if (Get.arguments != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.meetings.isEmpty) {
          // If no meetings loaded yet, fetch all first
          controller.fetchMeetings().then((_) {
            // Then fetch the specific meeting (will use cache)
            controller.fetchMeetingById(Get.arguments!);
          });
        } else {
          // If meetings already loaded, just fetch specific one
          controller.fetchMeetingById(Get.arguments!);
        }
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(
            title: 'Ringkasan Rapat',
            content:
                'Rapat koordinasi IT membahas progress proyek dan perencanaan ke depan. '
                'Tim sepakat untuk meningkatkan infrastruktur dan melakukan upgrade sistem.',
          ),
          const SizedBox(height: 20),
          const Text(
            'Keputusan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildDecisionItem('Upgrade server dilakukan bulan depan'),
          _buildDecisionItem('Budget IT dinaikkan 15%'),
          _buildDecisionItem('Rekrutmen programmer baru'),
          _buildDecisionItem('Implementasi sistem backup otomatis'),
          const SizedBox(height: 20),
          const Text(
            'Action Items',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildActionItem(
            task: 'Persiapan dokumen upgrade server',
            assignee: 'John Doe',
            deadline: '20 Jan 2025',
            status: 'In Progress',
          ),
          _buildActionItem(
            task: 'Review kandidat programmer',
            assignee: 'Brookly',
            deadline: '25 Jan 2025',
            status: 'Pending',
          ),
          _buildActionItem(
            task: 'Setup sistem backup',
            assignee: 'Steve',
            deadline: '30 Jan 2025',
            status: 'Not Started',
          ),
          const SizedBox(height: 20),
          _buildSummarySection(
            title: 'Rapat Berikutnya',
            content: 'Senin, 29 Januari 2025\n09:00 - 10:30 WIB\n TBA ',
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection({
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecisionItem(String decision) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              decision,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required String task,
    required String assignee,
    required String deadline,
    required String status,
  }) {
    Color statusColor;
    switch (status) {
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Pending':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                assignee,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(width: 16),
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                deadline,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
