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
import 'package:sirapat_app/presentation/shared/widgets/user_header_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/dashboard_stat_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';

/// Master Page - Single page layout dengan tab-based navigation
class MasterPage extends StatefulWidget {
  const MasterPage({super.key});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  int _currentIndex = 0;

  final List<BottomNavItem> _navItems = [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Beranda',
      route: '/home',
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
      label: 'Profile',
      route: '/profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _getCurrentSection()),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
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

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Card
            Padding(
              padding: AppSpacing.paddingLG,
              child: UserHeaderCard(
                userName: currentUser?.fullName ?? 'Admin',
                userNip: currentUser?.nip ?? '-',
                userRole: currentUser?.role,
              ),
            ),

            // Statistics Section
            Padding(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistik',
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Show skeleton while loading
                  if (isLoading) ...[
                    const StatCardSkeleton(),
                    SizedBox(height: AppSpacing.md),
                    const StatCardSkeleton(),
                  ] else ...[
                    DashboardStatCard(
                      title: 'Total User',
                      value: totalUsers.toString(),
                      icon: Icons.people,
                      backgroundColor: AppColors.accentTeal,
                      onTap: () {
                        setState(() {
                          _currentIndex = 1;
                        });
                      },
                    ),

                    SizedBox(height: AppSpacing.md),

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
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
