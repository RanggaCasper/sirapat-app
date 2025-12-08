import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';

class SummaryPage extends GetView<MeetingMinuteController> {
  final int meetingId;

  const SummaryPage({super.key, required this.meetingId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMeetingMinuteByMeetingId(meetingId);
    });

    return Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = Get.find<MeetingMinuteController>();
      if (data.errorMessage.isNotEmpty) {
        return Center(
          child: Text(
            'Error: ${data.errorMessage}',
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final decisions = data.decisions ?? [];

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// === Summary (content) ===
            _buildSummarySection(
              title: 'Ringkasan Rapat',
              content: data.content ?? "-",
            ),

            const SizedBox(height: 20),

            /// === Decisions ===
            const Text(
              'Keputusan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            if (decisions.isEmpty) const Text("Belum ada keputusan."),

            for (final item in decisions)
              _buildDecisionItem(item['title'] ?? "-"),
          ],
        ),
      );
    });
  }

  Widget _buildSummarySection({
    required String title,
    required String content,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary),
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
}
