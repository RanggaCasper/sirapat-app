import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/util/qr_download_helper.dart';
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
  final ParticipantController participantController =
      Get.find<ParticipantController>();
  late final TextEditingController identifierController;
  final GlobalKey _qrKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    identifierController = TextEditingController();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMeetingById(widget.meetingId);
    });
  }

  @override
  void dispose() {
    identifierController.dispose();
    _tabController.dispose();
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
            InfoPage(
              meeting: meeting,
              qrKey: _qrKey, // ⬅️ PASS QR KEY KE INFO PAGE
            ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
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
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
          child: SafeArea(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BottomSheetHandle(
                    margin: EdgeInsets.only(bottom: 20),
                  ),
                  ListTile(
                    leading: Icon(Icons.mic, color: AppColors.primary),
                    title: Text(
                      'Asisten Rapat',
                      style: TextStyle(color: AppColors.primary),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(
                        () => VoiceRecordPage(meetingId: widget.meetingId),
                        transition: Transition.rightToLeft,
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Ubah Rapat'),
                    onTap: () {
                      Navigator.pop(context);
                      final meeting = controller.selectedMeeting.value;
                      if (meeting != null) {
                        controller.prepareEdit(meeting);
                        Get.to(
                          () => EditMeetingPage(
                            meetingId: "${widget.meetingId}",
                          ),
                          transition: Transition.rightToLeft,
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Bagikan'),
                    onTap: () {
                      Navigator.pop(context);
                      _shareMeetingInfo();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      controller.deleteMeeting(widget.meetingId);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ⬅️ FUNGSI SHARE YANG SUDAH DIUPDATE
  void _shareMeetingInfo() async {
    final meeting = controller.selectedMeeting.value;
    if (meeting == null) return;

    try {
      final notif = Get.find<NotificationController>();

      // Cek apakah QR sudah ter-render
      final qrContext = _qrKey.currentContext;
      final needsRendering = qrContext == null;

      if (needsRendering) {
        // Tampilkan notifikasi bahwa akan beralih ke tab Info
        notif.showInfo('Mempersiapkan QR Code...');

        // Pindah ke tab Info (index 0)
        _tabController.animateTo(0);

        // Tunggu hingga tab selesai berpindah dan QR ter-render
        await Future.delayed(const Duration(milliseconds: 800));

        // Cek lagi apakah QR sudah ter-render
        final qrContextAfter = _qrKey.currentContext;
        if (qrContextAfter == null) {
          notif.showError(
            'Gagal memuat QR Code. Silakan coba lagi.',
          );
          return;
        }
      }

      // Tampilkan loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(),
        ),
        barrierDismissible: false,
      );

      final passcode =
          await controller.getMeetingPasscodeById(widget.meetingId);

      // Generate QR Code menggunakan QrDownloadHelper
      final qrFile = await QrDownloadHelper.generateQrCodeFile(
        repaintBoundaryKey: _qrKey,
        fileName: 'qr_share_${meeting.title}',
      );

      // Tutup loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      if (qrFile == null) {
        notif.showError(
          'Gagal membuat QR Code. Silakan coba lagi.',
        );
        return;
      }

      final message = """
📅 *Undangan Rapat*

Dengan hormat, Anda diundang untuk menghadiri rapat dengan detail berikut:

📝 *Judul Rapat* : ${meeting.title}
📆 *Tanggal*     : ${meeting.date}
⏰ *Waktu*       : ${meeting.startTime} – ${meeting.endTime}

🔑 *Kode Akses*  : $passcode
📷 *QR Code*     : Terlampir

Undangan ini dibagikan melalui *Aplikasi SiRapat*.
""";

      // Share dengan file QR Code
      await Share.shareXFiles(
        [XFile(qrFile.path)],
        text: message,
        subject: "Undangan Rapat: ${meeting.title}",
      );

      _copyToClipboard(message);
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back(); // Tutup loading jika masih ada
      }
      final notif = Get.find<NotificationController>();
      notif.showError('Gagal membagikan: ${e.toString()}');
      debugPrint('[MeetingDetailPage] Error sharing: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    final notif = Get.find<NotificationController>();
    notif.showSuccess('Teks undangan telah disalin ke clipboard');
  }

  Widget? _buildFloatingButton(Meeting meeting) {
    switch (_tabController.index) {
      case 0:
        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: _onChatButtonPressed,
          child: const Icon(Icons.chat_bubble),
        );

      case 1:
        return FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: _onChatButtonPressed,
          child: const Icon(Icons.chat_bubble),
        );

      case 2:
        return FutureBuilder<MeetingMinute?>(
          future: meetingMinuteController.getMeetingMinuteByMeetingId(
            meeting.id,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _onChatButtonPressed,
                child: const Icon(Icons.chat_bubble),
              );
            }

            if (snapshot.hasError) {
              return FloatingActionButton(
                backgroundColor: AppColors.primary,
                onPressed: _onChatButtonPressed,
                child: const Icon(Icons.chat_bubble),
              );
            }

            final meetingMinute = snapshot.data;
            final isApproved = meetingMinute?.approvedBy != null &&
                meetingMinute?.approvedAt != null;

            if (isApproved) {
              return const SizedBox.shrink();
            }

            return Align(
              alignment: Alignment.bottomRight,
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
            );
          },
        );

      default:
        return null;
    }
  }

  void _onNoteButtonPressed() async {
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
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BottomSheetHandle(margin: EdgeInsets.only(bottom: 20)),
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
                const Text(
                  'Setujui Notulen Rapat',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
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
                Row(
                  children: [
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
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final isLoading =
                            meetingMinuteController.isLoadingAction;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  final success = await meetingMinuteController
                                      .approveMeetingMinute(meetingMinute.id);

                                  if (!context.mounted) return;

                                  Navigator.pop(context);

                                  if (success) {
                                    setState(() {});
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
                                  'Setujui',
                                  style: TextStyle(
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
          ),
        );
      },
    );
  }
}
