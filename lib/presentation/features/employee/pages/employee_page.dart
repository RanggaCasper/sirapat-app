import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_button.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';
import 'package:sirapat_app/presentation/shared/widgets/user_header_card.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({Key? key}) : super(key: key);

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
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
        route: '/divisions',
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
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
            const SizedBox(width: 4),
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
    // TODO: Navigate to all meetings page
    print('View all meetings');
  }

  Widget _buildMeetingList() {
    final controller = Get.find<MeetingController>();

    return RefreshIndicator(
      onRefresh: controller.fetchMeetings,
      child: Obx(() {
        final meetings = controller.meetings;

        return Column(
          children: [
            Expanded(
              child: meetings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tidak ada rapat',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Cobalah tarik ke bawah untuk refresh.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetings[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: MeetingCard(
                            title: meeting.title,
                            date: meeting.date as DateTime,
                            onTap: () => _onMeetingCardTapped(meeting),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
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
    // TODO: Navigate to meeting detail page
    final title = meeting is Map ? meeting['title'] : meeting.title;
    print('Meeting tapped: $title');

    Get.snackbar(
      'Info',
      'Membuka detail rapat: $title',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
