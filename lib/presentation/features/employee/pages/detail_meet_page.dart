import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/controllers/chat_binding.dart';
import 'package:sirapat_app/presentation/features/chat/pages/chat_meet_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/info_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/participant_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/summary_page.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';

class DetailMeetPage extends StatefulWidget {
  final int? meetingId;

  const DetailMeetPage({super.key, this.meetingId});

  @override
  State<DetailMeetPage> createState() => _DetailMeetPageState();
}

class _DetailMeetPageState extends State<DetailMeetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MeetingController controller = Get.find<MeetingController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {});
    });
    // Fetch meeting detail when page loads using meetingId parameter
    if (widget.meetingId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchMeetingById(widget.meetingId!);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Clear selected meeting to prevent stale data on next navigation
    controller.selectedMeeting.value = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final meeting = controller.selectedMeeting.value;

      if (meeting == null) {
        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            title: const Text('Memuat...'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: const Center(child: CircularProgressIndicator()),
        );
      }

      return Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: _buildAppBar(meeting),
        body: TabBarView(
          controller: _tabController,
          children: [
            InfoPage(meeting: meeting),
            ParticipantPage(meeting: meeting),
            SummaryPage(meetingId: meeting.id),
          ],
        ),
        floatingActionButton: _buildFloatingButton(meeting),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(Meeting meeting) {
    return AppBar(
      title: Text(meeting.title),
      centerTitle: false,
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: 'Info'),
          Tab(text: 'Peserta'),
          Tab(text: 'Summary'),
        ],
      ),
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    );
  }

  void _onChatButtonPressed() {
    final meeting = controller.selectedMeeting.value;
    if (meeting != null) {
      Get.to(
        ChatMeetPage(meetingId: meeting.id),
        binding: ChatBinding(),
        transition: Transition.rightToLeft,
      );
    }
  }

  Widget? _buildFloatingButton(Meeting meeting) {
    // Employee tidak punya fitur tambah peserta, hanya chat di semua tab
    return FloatingActionButton(
      backgroundColor: AppColors.primary,
      onPressed: _onChatButtonPressed,
      child: const Icon(Icons.chat_bubble),
    );
  }
}
