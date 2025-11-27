import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/history_meet_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/features/qr_scanner/pages/qr_scanner_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';
import 'package:sirapat_app/presentation/shared/widgets/user_header_card.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  int _currentIndex = 0;
  final TextEditingController _meetingCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getCurrentSection()),
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
        route: '/empolyee-dashboard',
      ),
      BottomNavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Pindai',
        route: '/users',
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
        label: 'Profile',
        route: '/profile',
      ),
    ];
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentSection() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeSection();
      case 1:
        return const QrScannerPage();
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

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserHeader(currentUser),
            _buildMeetingCodeCard(),
            _buildMeetingListHeader(),
            _buildMeetingList(),
          ],
        ),
      );
    });
  }

  Widget _buildUserHeader(dynamic currentUser) {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: UserHeaderCard(
        userName: currentUser?.fullName ?? 'Admin',
        userNip: currentUser?.nip ?? '-',
        userRole: currentUser?.role,
      ),
    );
  }

  Widget _buildMeetingCodeCard() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusLG,
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Masukkan Kode Rapat', style: AppTextStyles.subtitle),
            const SizedBox(height: AppSpacing.md),
            _buildMeetingCodeInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingCodeInput() {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: 'Contoh: MTG-12345',
            controller: _meetingCodeController,
            textColor: AppColors.textDark,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        CustomButton(
          text: 'Ikuti',
          height: 50,
          width: 90,
          borderRadius: 12,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.cardBackground,
          onPressed: _onJoinMeetingPressed,
        ),
      ],
    );
  }

  Widget _buildMeetingListHeader() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('List Rapat', style: AppTextStyles.title),
          _buildViewAllButton(),
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return InkWell(
      onTap: _onViewAllPressed,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Text(
              'Lihat Semua',
              style: AppTextStyles.title.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: AppIconSize.sm,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _onJoinMeetingPressed() {
    final meetingController = Get.find<MeetingController>();
    final notif = Get.find<NotificationController>();
    final meetingCode = _meetingCodeController.text.trim();

    if (meetingCode.isEmpty) {
      notif.showError('Silakan masukkan kode rapat');
      return;
    }

    // Call join meeting API
    meetingController.joinMeetingByCode(meetingCode);

    // Clear input field after successful/failed attempt
    _meetingCodeController.clear();
  }

  void _onViewAllPressed() {
    setState(() {
      _currentIndex = 2; // Index 2 is Rapat
    });
  }

  Widget _buildMeetingList() {
    final meetingController = Get.find<MeetingController>();

    return Obx(() {
      if (meetingController.isLoading) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: const MeetingCardSkeleton(),
              ),
            ),
          ),
        );
      }

      final meetings = meetingController.meetings;

      if (meetings.isEmpty) {
        return _buildEmptyMeetingState();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            ...meetings.map(
              (meeting) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: MeetingCard(
                  title: meeting.title,
                  date: DateTime.parse(meeting.date),
                  onTap: () => _onMeetingCardTapped(meeting),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyMeetingState() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada rapat',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _onMeetingCardTapped(dynamic meeting) {
    // Navigate to meeting detail page with ID
    final meetingId = meeting is Map ? meeting['id'] : meeting.id;
    final notif = Get.find<NotificationController>();

    if (meetingId == null) {
      notif.showError('ID rapat tidak ditemukan');
      return;
    }

    // Navigate to detail page with meeting ID
    Get.to(
      DetailMeetPage(meetingId: meetingId),
      transition: Transition.rightToLeft,
      arguments: meetingId,
    );
  }
}
