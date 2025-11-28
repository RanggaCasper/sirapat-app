import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_title.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/more_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_info_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_summary_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/chat_button.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/pages/chat_meet_page.dart';

class DetailMeetPage extends GetView<MeetingController> {
  final int? meetingId;

  const DetailMeetPage({Key? key, this.meetingId}) : super(key: key);

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Get.back(),
        ),
        title: Obx(
          () => MeetingTitle(
            title: controller.selectedMeeting.value?.title ?? 'Detail Rapat',
          ),
        ),
        actions: const [MoreButton()],
      ),
      body: Obx(() {
        if (controller.isLoadingActionObs.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryDark),
          );
        }

        if (controller.selectedMeeting.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: AppIconSize.xxl,
                  color: AppColors.gray,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Data rapat tidak ditemukan',
                  style: TextStyle(fontSize: 16, color: AppColors.gray),
                ),
                const SizedBox(height: AppSpacing.lg),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                  ),
                  child: const Text('Kembali'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (Get.arguments != null) {
              await controller.fetchMeetingById(Get.arguments!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                MeetingInfoCard(meeting: controller.selectedMeeting.value!),
                const SizedBox(height: AppSpacing.lg),
                Obx(
                  () => MeetingSummaryCard(
                    meeting: controller.selectedMeeting.value!,
                    isLoading: controller.isLoadingActionObs.value,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
      floatingActionButton: ChatButton(onPressed: _onChatButtonPressed),
    );
  }

  void _onChatButtonPressed() {
    final meeting = controller.selectedMeeting.value;
    if (meeting != null) {
      Get.to(
        ChatMeetPage(meetingId: meeting.id),
        transition: Transition.rightToLeft,
      );
    }
  }
}
