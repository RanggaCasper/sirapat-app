import 'package:flutter/material.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'info_item.dart';

class MeetingInfoCard extends StatelessWidget {
  final Meeting? meeting;

  const MeetingInfoCard({Key? key, this.meeting}) : super(key: key);

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return 'Terjadwal';
      case 'ongoing':
        return 'Sedang Berlangsung';
      case 'completed':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return const Color(0xFF3B82F6);
      case 'ongoing':
        return const Color(0xFFEF4444);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = '${meeting?.startTime} - ${meeting?.endTime}';
    final location = meeting?.location ?? 'Lokasi tidak ditentukan';
    final statusColor = _getStatusColor(meeting?.status ?? 'scheduled');

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        children: [
          InfoItem(
            icon: Icons.calendar_today,
            text: timeRange,
            iconColor: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          InfoItem(
            icon: Icons.location_on,
            text: location,
            iconColor: const Color(0xFFEF4444),
          ),
          const SizedBox(height: 12),
          InfoItem(
            icon: Icons.circle,
            text: _getStatusLabel(meeting?.status ?? 'scheduled'),
            iconColor: statusColor,
          ),
        ],
      ),
    );
  }
}
