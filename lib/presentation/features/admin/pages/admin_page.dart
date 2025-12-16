import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/features/admin/pages/meetings_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

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
        route: '/admin-dashboard',
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
        label: 'Profil',
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
        return const SafeArea(child: MeetingsPage());
      case 2:
        return const ProfilePage();
      default:
        return _buildHomeSection();
    }
  }

  Widget _buildHomeSection() {
    final authController = Get.find<AuthController>();

    return Obx(() {
      final currentUser = authController.currentUser;

      return CustomScrollView(
        slivers: [
          _buildSliverAppBar(currentUser),
          SliverToBoxAdapter(child: _buildQuickActions()),
          SliverToBoxAdapter(child: _buildMeetingListHeader()),
          _buildMeetingListSliver(),
        ],
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
    final fullName = currentUser?.fullName ?? 'Admin';
    final role = currentUser?.role ?? 'Admin';

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
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _getRoleLabel(role),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'master':
        return 'Master Admin';
      case 'employee':
        return 'Karyawan';
      default:
        return 'Admin';
    }
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Aksi Cepat', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  icon: Icons.add_circle_outline,
                  title: 'Buat Rapat',
                  subtitle: 'Rapat baru',
                  color: AppColors.success,
                  onTap: () => Get.toNamed('/admin-create-meeting'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.calendar_month_outlined,
                  title: 'Kelola Rapat',
                  subtitle: 'Lihat semua',
                  color: AppColors.primary,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
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
                'Daftar Rapat',
                style: AppTextStyles.title.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Kelola rapat yang tersedia',
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

  void _onViewAllPressed() {
    setState(() {
      _currentIndex = 1;
    });
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
              'Buat rapat baru untuk memulai',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _onMeetingCardTapped(dynamic meeting) {
    Get.toNamed('/admin-meeting-detail', arguments: meeting.id);
  }
}
