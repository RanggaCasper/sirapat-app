import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
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
        return AppColors.info;
      case 'ongoing':
        return AppColors.error;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.gray;
      default:
        return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeRange = '${meeting?.startTime} - ${meeting?.endTime}';
    final location = meeting?.location ?? 'Lokasi tidak ditentukan';
    final statusColor = _getStatusColor(meeting?.status ?? 'scheduled');

    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.kLightBlueBg,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          InfoItem(
            icon: Icons.calendar_today,
            text: timeRange,
            iconColor: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.md),
          InfoItem(
            icon: Icons.location_on,
            text: location,
            iconColor: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
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
