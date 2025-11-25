import 'package:flutter/material.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_title.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/more_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_info_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/meeting_summary_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/chat_button.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class DetailMeetPage extends StatefulWidget {
  final int? meetingId;

  const DetailMeetPage({Key? key, this.meetingId}) : super(key: key);

  @override
  State<DetailMeetPage> createState() => _DetailMeetPageState();
}

class _DetailMeetPageState extends State<DetailMeetPage> {
  late MeetingController controller;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    if (!Get.isRegistered<MeetingController>()) {
      MeetingBinding().dependencies();
    }
    controller = Get.find<MeetingController>();

    // Fetch all meetings first if empty, then get specific meeting
    if (Get.arguments != null) {
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A8A)),
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
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
          );
        }

        if (controller.selectedMeeting.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Data rapat tidak ditemukan',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
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
                const SizedBox(height: 16),
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
      floatingActionButton: const ChatButton(),
    );
  }
}
