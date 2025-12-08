import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/presentation/controllers/chat_binding.dart';
import 'package:sirapat_app/presentation/features/chat/pages/chat_meet_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/info_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/participant_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/summary_page.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/controllers/participant_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';

class MeetingDetailPage extends StatefulWidget {
  final int meetingId;

  const MeetingDetailPage({super.key, required this.meetingId});

  @override
  State<MeetingDetailPage> createState() => _MeetingDetailPageState();
}

class _MeetingDetailPageState extends State<MeetingDetailPage>
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
    // Fetch meeting detail when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMeetingById(widget.meetingId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            title: const Text('Loading...'),
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
    Get.to(
      ChatMeetPage(meetingId: widget.meetingId),
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
            // Handle indicator
            const BottomSheetHandle(margin: EdgeInsets.only(bottom: 20)),
            // Meeting Assistant feature commented out (flutter_sound removed)
            // ListTile(
            //   leading: Icon(Icons.mic, color: AppColors.primary),
            //   title: Text(
            //     'Meeting Assistant',
            //     style: TextStyle(color: AppColors.primary),
            //   ),
            //   onTap: () {
            //     Get.to(
            //       () => VoiceRecordPage(meetingId: widget.meetingId),
            //       transition: Transition.rightToLeft,
            //     );
            //   },
            // ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Rapat'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan'),
              onTap: () {
                _shareMeetingInfo();
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onTap: () {
                controller.deleteMeeting(widget.meetingId);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _shareMeetingInfo() async {
    final meeting = controller.selectedMeeting.value;
    if (meeting == null) return;

    final passcode = await controller.getMeetingPasscodeById(widget.meetingId);
    final message =
        """
          📅 *Undangan Rapat*
          Judul: ${meeting.title}
          Tanggal: ${meeting.date}
          Waktu: ${meeting.startTime} - ${meeting.endTime}

          🔑 *Passcode:* $passcode
          🔗 *Link Join:* (masukkan link jika ada)
          📷 *QR Code tersedia pada aplikasi*

          Dibagikan via *SiRapat App*
          """;

    Share.share(message, subject: "Undangan Rapat: ${meeting.title}");
    _copyToClipboard(message);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Disalin",
      "Teks undangan telah disalin ke clipboard",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget? _buildFloatingButton(Meeting meeting) {
    switch (_tabController.index) {
      case 0:
        // Tab Info: Chat button
        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: _onChatButtonPressed,
          child: const Icon(Icons.chat_bubble),
        );

      case 1:
        // Tab Peserta: Tambah peserta (hanya admin)
        return FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            _showInviteBottomSheet(context);
          },
          child: const Icon(Icons.person_add),
        );

      case 2:
        // Tab Summary: Chat button
        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: _onChatButtonPressed,
          child: const Icon(Icons.chat_bubble),
        );

      default:
        return null;
    }
  }

  void _showInviteBottomSheet(BuildContext context) {
    final ParticipantController participantController =
        Get.find<ParticipantController>();
    final TextEditingController identifierController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle indicator
              const Center(
                child: BottomSheetHandle(margin: EdgeInsets.only(bottom: 16)),
              ),
              Text(
                "Invite Participant",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: identifierController,
                decoration: InputDecoration(
                  labelText: "Email / Phone Number / NIP",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final identifier = identifierController.text.trim();
                    participantController.inviteParticipant(
                      meetingId: widget.meetingId,
                      identifier: identifier,
                    );
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.send),
                  label: const Text("Send Invitation"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
