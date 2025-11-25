import 'package:flutter/material.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'summary_header.dart';
import 'summary_description.dart';
import 'section_title.dart';
import 'bullet_point.dart';

class MeetingSummaryCard extends StatelessWidget {
  final Meeting? meeting;
  final bool isLoading;

  const MeetingSummaryCard({Key? key, this.meeting, this.isLoading = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const SummaryHeader(),
          const SizedBox(height: 16),
          SummaryDescription(description: meeting?.description),
          const SizedBox(height: 16),
          const SectionTitle(title: '📌 Agenda'),
          const SizedBox(height: 8),
          BulletPoint(text: meeting?.agenda ?? 'Tidak ada agenda'),
          if (meeting?.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            const SectionTitle(title: '📝 Detail Tambahan'),
            const SizedBox(height: 8),
            Text(
              meeting!.description!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
