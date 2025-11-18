import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/widgets/custom_button.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class LogoutButton extends StatelessWidget {
  final bool isLoading;

  const LogoutButton({super.key, this.isLoading = false});

  // Fungsi menampilkan dialog logout
  void _showLogoutDialog(BuildContext context) {
    final controller = Get.find<AuthController>();

    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Logout',
      icon: Icons.logout,
      isLoading: isLoading,
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      width: double.infinity,
      onPressed: () => _showLogoutDialog(context),
    );
  }
}
