import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/presentation/shared/widgets/meet/chat_button.dart';
import 'package:sirapat_app/presentation/controllers/chat_binding.dart';
import 'package:sirapat_app/presentation/features/chat/pages/chat_meet_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/info_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/participant_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/summary_page.dart';

class MeetingDetailPage extends StatefulWidget {
  final Meeting meeting;

  const MeetingDetailPage({Key? key, required this.meeting}) : super(key: key);

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          InfoPage(meeting: widget.meeting),
          ParticipantPage(meeting: widget.meeting),
          SummaryPage(meeting: widget.meeting),
        ],
      ),
      floatingActionButton: ChatButton(onPressed: _onChatButtonPressed),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(widget.meeting.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showOptionsMenu(context),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white70,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
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
    Get.to(
      ChatMeetPage(meetingId: widget.meeting.id),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Rapat'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit page
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement delete functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
