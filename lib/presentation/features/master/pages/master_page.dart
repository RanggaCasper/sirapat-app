import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';
import 'package:sirapat_app/presentation/controllers/user_controller.dart';
import 'package:sirapat_app/presentation/features/master/pages/division/division_page.dart';
import 'package:sirapat_app/presentation/features/master/pages/user/user_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_bottom_nav_bar.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';
import 'package:sirapat_app/presentation/shared/widgets/dashboard_stat_card.dart';

class MasterPage extends StatefulWidget {
  const MasterPage({super.key});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _currentIndex = 0;

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
        route: '/master-dashboard',
      ),
      BottomNavItem(
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        label: 'Pengguna',
        route: '/users',
      ),
      BottomNavItem(
        icon: Icons.business_outlined,
        activeIcon: Icons.business,
        label: 'Divisi',
        route: '/divisions',
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
        return const UserManagementSection();
      case 2:
        return const DivisionManagementSection();
      case 3:
        return const ProfilePage();
      default:
        return _buildHomeSection();
    }
  }

  Widget _buildHomeSection() {
    final divisionController = Get.find<DivisionController>();
    final userController = Get.find<UserController>();
    final authController = Get.find<AuthController>();

    return Obx(() {
      final isLoading =
          divisionController.isLoading || userController.isLoading;
      final totalDivisions = divisionController.totalCount.value;
      final totalUsers = userController.totalCount.value;
      final currentUser = authController.currentUser;

      return CustomScrollView(
        slivers: [
          _buildSliverAppBar(currentUser),
          SliverToBoxAdapter(child: _buildQuickActions()),
          SliverToBoxAdapter(
            child: _buildStatisticsSection(
              isLoading,
              totalUsers,
              totalDivisions,
            ),
          ),
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
    final fullName = currentUser?.fullName ?? 'Master Admin';
    final role = currentUser?.role ?? 'Master';

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
        return 'Administrator';
      case 'master':
        return 'Master Admin';
      case 'employee':
        return 'Karyawan';
      default:
        return 'Master Admin';
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
                  icon: Icons.people_outline,
                  title: 'Kelola Pengguna',
                  subtitle: 'Lihat semua',
                  color: AppColors.accentTeal,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildActionCard(
                  icon: Icons.business_outlined,
                  title: 'Kelola Divisi',
                  subtitle: 'Lihat semua',
                  color: AppColors.accentPurple,
                  onTap: () => setState(() => _currentIndex = 2),
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

  Widget _buildStatisticsSection(
    bool isLoading,
    int totalUsers,
    int totalDivisions,
  ) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
            style: AppTextStyles.title.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading) ...[
            const StatCardSkeleton(),
            const SizedBox(height: 12),
            const StatCardSkeleton(),
          ] else ...[
            DashboardStatCard(
              title: 'Total Pengguna',
              value: totalUsers.toString(),
              icon: Icons.people,
              backgroundColor: AppColors.accentTeal,
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            const SizedBox(height: 12),
            DashboardStatCard(
              title: 'Total Divisi',
              value: totalDivisions.toString(),
              icon: Icons.business,
              backgroundColor: AppColors.accentPurple,
              onTap: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
