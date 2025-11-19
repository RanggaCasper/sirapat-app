import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/widgets/custom_bottom_nav_bar.dart';

class AdminBottomNavbar extends StatelessWidget {
  final int currentIndex;

  const AdminBottomNavbar({super.key, required this.currentIndex});

  List<BottomNavItem> get adminNavItems => [
    BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: "Home",
      route: "/admin-dashboard",
    ),
    BottomNavItem(
      icon: Icons.qr_code_scanner_outlined,
      activeIcon: Icons.qr_code_scanner,
      label: "Scan",
      route: "/admin-scan",
    ),
    BottomNavItem(
      icon: Icons.video_call_outlined,
      activeIcon: Icons.video_call,
      label: "Rapat",
      route: "/admin-list-rapat",
    ),
    BottomNavItem(
      icon: Icons.history_outlined,
      activeIcon: Icons.history,
      label: "Riwayat",
      route: "/admin-riwayat",
    ),
    BottomNavItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: "Profil",
      route: "/admin-profil",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomBottomNavBar(
      currentIndex: currentIndex,
      items: adminNavItems,
      onTap: (index) {
        Get.toNamed(adminNavItems[index].route);
      },
    );
  }
}
