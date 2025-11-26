import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/features/admin/sections/meeting_management_section.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/features/qr_scanner/pages/qr_scanner_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';
import 'package:sirapat_app/presentation/shared/widgets/user_header_card.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;
  final TextEditingController _meetingCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize bindings
    MeetingBinding().dependencies();
  }

  // void dispose() {
  //   _meetingCodeController.dispose();
  //   super.dispose();
  // }

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
        route: '/admin-dashboard',
      ),
      BottomNavItem(
        icon: Icons.qr_code_scanner_outlined,
        activeIcon: Icons.qr_code_scanner,
        label: 'Pindai',
        route: '/users',
      ),
      BottomNavItem(
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        label: 'Rapat',
        route: '/admin-create-meeting',
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
        return const MeetingManagementSection();
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
          Row(children: [_buildViewAllButton()]),
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
    final meetingCode = _meetingCodeController.text.trim();

    if (meetingCode.isEmpty) {
      Get.snackbar(
        'Error',
        'Silakan masukkan kode rapat',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Implement join meeting logic
    print('Join meeting with code: $meetingCode');
  }

  void _onViewAllPressed() {
    // Navigate to Rapat section by changing bottom nav index
    setState(() {
      _currentIndex = 2; // Index 2 is Rapat
    });
  }

  Widget _buildMeetingList() {
    final meetingController = Get.find<MeetingController>();

    return Obx(() {
      // Show loading indicator
      if (meetingController.isLoading) {
        return const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      final meetings = meetingController.meetings;

      debugPrint('[AdminPage] Meetings count: ${meetings.length}');

      if (meetings.isEmpty) {
        return _buildEmptyMeetingState();
      }

      // Only show first 5 meetings on home page
      final displayedMeetings = meetings.take(5).toList();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [
            ...displayedMeetings.map(
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
    // Navigate to meeting detail page
    Get.toNamed('/admin-meeting-detail', arguments: meeting);
  }
}
