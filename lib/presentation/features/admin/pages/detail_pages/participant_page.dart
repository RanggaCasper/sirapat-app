import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
            const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          final attendance = attendanceList[index];
          return _buildParticipantTile(attendance);
        },
      );
    });
  }

  Widget _buildParticipantTile(Attendance attendance) {
    final participant = attendance.participant;
    final statusColor = attendance.isPresent ? Colors.green : Colors.orange;
    final statusText = attendance.statusDisplay;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        radius: 24,
        child: Text(
          participant?.fullName?.isNotEmpty == true
              ? participant!.fullName![0].toUpperCase()
              : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: statusColor,
          ),
        ),
      ),
      title: Text(
        participant?.fullName ?? 'Unknown',
        style: AppTextStyles.title.copyWith(fontSize: 15),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              participant?.nip ?? '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Check-in: ${attendance.checkInTime}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
      trailing: Container(
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
    );
  }
}
