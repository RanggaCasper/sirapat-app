import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/domain/entities/attendance.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/usecases/attendance/get_attendance_usecase.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';

class ParticipantPage extends StatefulWidget {
  final Meeting meeting;

  const ParticipantPage({super.key, required this.meeting});

  @override
  State<ParticipantPage> createState() => _ParticipantPageState();
}

class _ParticipantPageState extends State<ParticipantPage> {
  late GetAttendanceUseCase _getAttendanceUseCase;
  late RxList<Attendance> attendanceList = <Attendance>[].obs;
  late RxBool isLoadingAttendance = false.obs;

  @override
  void initState() {
    super.initState();
    _getAttendanceUseCase = Get.find<GetAttendanceUseCase>();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    try {
      isLoadingAttendance.value = true;
      final attendance = await _getAttendanceUseCase(widget.meeting.id);
      attendanceList.assignAll(attendance);
    } catch (e) {
      debugPrint('[ParticipantPage] Error loading attendance: $e');
    } finally {
      isLoadingAttendance.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (isLoadingAttendance.value) {
        return ListView.builder(
          padding: EdgeInsets.all(AppSpacing.lg),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonLoader(
              height: 80,
              borderRadius: BorderRadius.circular(12),
              width: double.infinity,
            ),
          ),
        );
      }

      if (attendanceList.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Belum ada peserta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Data peserta akan ditampilkan di sini',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: attendanceList.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          return _buildParticipantCard(attendance);
        },
      );
    });
  }

  Widget _buildParticipantCard(Attendance attendance) {
    final participant = attendance.participant;
    final statusColor = attendance.isPresent ? Colors.green : Colors.orange;
    final statusText = attendance.statusDisplay;

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusLG,
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          // Avatar Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                participant?.fullName?.isNotEmpty == true
                    ? participant!.fullName![0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant?.fullName ?? 'Unknown',
                  style: AppTextStyles.title.copyWith(
                    fontSize: AppTextStyles.body.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: AppIconSize.sm,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${attendance.checkInTime}',
                      style: AppTextStyles.body.copyWith(
                        fontSize: AppTextStyles.caption.fontSize,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
