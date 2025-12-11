import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/presentation/controllers/chat_binding.dart';
import 'package:sirapat_app/presentation/features/admin/pages/edit_meeting_page.dart';
import 'package:sirapat_app/presentation/features/chat/pages/chat_meet_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/info_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/participant_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/detail_pages/summary_page.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/controllers/participant_controller.dart';
import 'package:sirapat_app/presentation/features/voice_assistant/pages/voice_assistant_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/domain/entities/meeting_minute.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

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
  final MeetingMinuteController meetingMinuteController =
      Get.find<MeetingMinuteController>();

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
    // Clear selected meeting to prevent stale data
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
            title: const Text('Loading...'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                controller.selectedMeeting.value = null;
                Get.back();
              },
            ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          // Clear selected meeting and go back
          controller.selectedMeeting.value = null;
          Get.back();
        },
      ),
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
            ListTile(
              leading: Icon(Icons.mic, color: AppColors.primary),
              title: Text(
                'Meeting Assistant',
                style: TextStyle(color: AppColors.primary),
              ),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet first
                Get.to(
                  () => VoiceRecordPage(meetingId: widget.meetingId),
                  transition: Transition.rightToLeft,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Rapat'),
              onTap: () {
                Navigator.pop(context); // Close bottom sheet first

                // Ensure meeting data is available for edit
                final meeting = controller.selectedMeeting.value;
                if (meeting != null) {
                  controller.prepareEdit(meeting);
                  Get.to(
                    () => EditMeetingPage(meetingId: "${widget.meetingId}"),
                    transition: Transition.rightToLeft,
                  );
                }
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
                Navigator.pop(context);
                controller.deleteMeeting(widget.meetingId);
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
    final notif = Get.find<NotificationController>();
    notif.showSuccess('Teks undangan telah disalin ke clipboard');
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
        return FutureBuilder<MeetingMinute?>(
          future: meetingMinuteController.getMeetingMinuteByMeetingId(
            meeting.id,
          ),
          builder: (context, snapshot) {
            // Sementara loading → tampilkan chat button
            if (snapshot.connectionState == ConnectionState.waiting) {
              return FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _onChatButtonPressed,
                child: const Icon(Icons.chat_bubble),
              );
            }

            // Jika error → tampilkan chat button
            if (snapshot.hasError) {
              return FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _onChatButtonPressed,
                child: const Icon(Icons.chat_bubble),
              );
            }

            final meetingMinute = snapshot.data;

            // Cek approved
            final isApproved =
                meetingMinute?.approvedBy != null &&
                meetingMinute?.approvedAt != null;

            // Jika sudah approved → TIDAK tampilkan tombol apa pun
            if (isApproved) {
              return const SizedBox.shrink(); // penting!
            }

            // Jika belum approved → tampil 2 tombol
            return Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10, bottom: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FloatingActionButton(
                      backgroundColor: AppColors.accentRed,
                      onPressed: _onNoteButtonPressed,
                      child: const Icon(Icons.edit_note),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      backgroundColor: AppColors.primary,
                      onPressed: _onChatButtonPressed,
                      child: const Icon(Icons.chat_bubble),
                    ),
                  ],
                ),
              ),
            );
          },
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

  void _onNoteButtonPressed() async {
    // Ambil data meeting minute terlebih dahulu
    final meetingMinute = await meetingMinuteController
        .getMeetingMinuteByMeetingId(widget.meetingId);

    if (meetingMinute == null) {
      final notif = Get.find<NotificationController>();
      notif.showError('Notulen rapat tidak ditemukan');
      return;
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle indicator
              const BottomSheetHandle(margin: EdgeInsets.only(bottom: 20)),

              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Approve Notulen Rapat',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Apakah Anda yakin ingin menyetujui notulen rapat ini?',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Approve Button
                  Expanded(
                    child: Obx(() {
                      final isLoading = meetingMinuteController.isLoadingAction;

                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                // Call approve method dari controller
                                final success = await meetingMinuteController
                                    .approveMeetingMinute(meetingMinute.id);

                                if (!context.mounted) return;

                                Navigator.pop(context);

                                if (success) {
                                  // Refresh halaman summary
                                  setState(() {});

                                  // Show success message
                                  final notif =
                                      Get.find<NotificationController>();
                                  notif.showSuccess(
                                    'Notulen rapat telah disetujui',
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'Approve',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
