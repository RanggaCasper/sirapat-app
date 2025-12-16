import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/history_meet_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/features/qr_scanner/qr_scanner_bottom_sheet.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/participant_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/domain/usecases/attendance/get_attendance_usecase.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  int _currentIndex = 0;
  final TextEditingController _meetingCodeController = TextEditingController();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _meetingCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(top: false, child: _getCurrentSection()),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
        items: _buildNavItems(),
      ),
    );
  }

  List<BottomNavItem> _buildNavItems() {
    return [
      BottomNavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Beranda',
        route: '/employee-dashboard',
      ),
      BottomNavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Pindai',
        route: '/qr-scanner',
      ),
      BottomNavItem(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Riwayat',
        route: '/employee-history-meeting',
      ),
      BottomNavItem(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profil',
        route: '/profile',
      ),
    ];
  }

  void _onNavItemTapped(int index) {
    if (index == 1) {
      showQrScannerBottomSheet();
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentSection() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeSection();
      case 2:
        return const HistoryMeetPage();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeSection();
    }
  }

  Widget _buildHomeSection() {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final currentUser = authController.currentUser;

      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildSliverAppBar(currentUser),
            SliverToBoxAdapter(child: _buildMeetingCodeCard()),
            SliverToBoxAdapter(child: _buildMeetingListHeader()),
            _buildMeetingListSliver(),
          ],
        ),
      );
    });
  }

  Widget _buildSliverAppBar(dynamic currentUser) {
    return SliverAppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 160,
      automaticallyImplyLeading: false,
      pinned: false,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeaderGradient(currentUser),
      ),
    );
  }

  Widget _buildHeaderGradient(dynamic currentUser) {
    return Container(
      decoration: BoxDecoration(color: AppColors.primary),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [_buildWelcomeMessage(currentUser)],
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage(dynamic currentUser) {
    final fullName = currentUser?.fullName ?? 'Pengguna';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat datang kembali 👋',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          fullName,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                "Karyawan",
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMeetingCodeCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Masukkan Kode Rapat',
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bergabunglah dengan rapat menggunakan kode',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMeetingCodeInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCodeInput() {
    final meetingController = Get.find<MeetingController>();
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => CustomTextField(
              hintText: 'Contoh: MTG-12345',
              controller: _meetingCodeController,
              textColor: AppColors.textDark,
              prefixIcon: Icons.qr_code_2_outlined,
              errorText: meetingController.fieldErrors['meeting_code'],
              onChanged: (value) {
                if (meetingController.fieldErrors['meeting_code'] != null) {
                  meetingController.fieldErrors.remove('meeting_code');
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        CustomButton(
          text: 'Ikuti',
          height: 50,
          width: 90,
          borderRadius: 12,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          onPressed: _onJoinMeetingPressed,
        ),
      ],
    );
  }

  Widget _buildMeetingListHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rapat Anda',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar rapat yang tersedia',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onViewAllPressed,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primary.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingListSliver() {
    final meetingController = Get.find<MeetingController>();

    return Obx(() {
      if (meetingController.isLoading) {
        return _buildLoadingSliverList();
      }

      final meetings = meetingController.meetings;
      final limitedMeetings = meetings.take(5).toList();

      if (meetings.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyMeetingState());
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final meeting = limitedMeetings[index];
            final isLastItem = index == limitedMeetings.length - 1;

            return Padding(
              padding: EdgeInsets.only(bottom: isLastItem ? 24 : 12),
              child: _buildMeetingCardWrapper(meeting),
            );
          }, childCount: limitedMeetings.length),
        ),
      );
    });
  }

  Widget _buildLoadingSliverList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: const MeetingCardSkeleton(),
          ),
          childCount: 4,
        ),
      ),
    );
  }

  Widget _buildMeetingCardWrapper(dynamic meeting) {
    return GestureDetector(
      onTap: () => _onMeetingCardTapped(meeting),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: MeetingCard(
          title: meeting.title,
          date: DateTime.parse(meeting.date),
          onTap: () => _onMeetingCardTapped(meeting),
        ),
      ),
    );
  }

  Widget _buildEmptyMeetingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_busy_outlined,
                size: 48,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada rapat',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rapat yang tersedia akan muncul di sini',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28)
          ],
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final meetingController = Get.find<MeetingController>();
    await meetingController.fetchMeetings();
  }

  void _onJoinMeetingPressed() async {
    final meetingController = Get.find<MeetingController>();
    final meetingCode = _meetingCodeController.text.trim();

    await meetingController.joinMeetingByCode(meetingCode);

    // Clear field only if no error after join
    if (meetingController.fieldErrors['meeting_code'] == null) {
      _meetingCodeController.clear();
    }
  }

  void _onViewAllPressed() {
    setState(() {
      _currentIndex = 2;
    });
  }

  void _onMeetingCardTapped(dynamic meeting) {
    final meetingId = meeting is Map ? meeting['id'] : meeting.id;
    final notif = Get.find<NotificationController>();

    if (meetingId == null) {
      notif.showError('ID rapat tidak ditemukan');
      return;
    }

    final meetingController = Get.find<MeetingController>();
    meetingController.selectedMeeting.value = null;

    Get.to(
      () => DetailMeetPage(meetingId: meetingId),
      binding: BindingsBuilder(() {
        if (!Get.isRegistered<GetAttendanceUseCase>()) {
          MeetingBinding().dependencies();
          ParticipantBinding().dependencies();
          MeetingMinuteBinding().dependencies();
        }
      }),
      transition: Transition.rightToLeft,
    );
  }
}
