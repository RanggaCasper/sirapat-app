import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/user_binding.dart';
import 'package:sirapat_app/presentation/controllers/division_binding.dart';
import 'package:sirapat_app/presentation/features/profile/pages/edit_user_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/user_info_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/change_password_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/presentation/widgets/update_dialog.dart';

class ProfilePage extends GetView<AuthController> {
  const ProfilePage({super.key});

  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  String _getRoleLabel(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'master':
        return 'Master';
      case 'employee':
        return 'Karyawan';
      default:
        return 'Karyawan';
    }
  }

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.orange;
      case 'master':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 20),
              _buildAccountSection(context),
              const SizedBox(height: 16),
              _buildSettingsSection(),
              const SizedBox(height: 16),
              _buildAboutSection(context),
              const SizedBox(height: 24),
              _buildLogoutButton(context),
              const SizedBox(height: 24)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final topPadding = MediaQuery.of(Get.context!).padding.top;

    return Obx(
      () => Stack(
        children: [
          // 🔵 BACKGROUND BIRU (DINAMIS)
          Positioned.fill(
            child: Container(
              color: AppColors.primary,
            ),
          ),

          // ✅ CONTENT (AMAN & TIDAK TERGESER)
          Padding(
            padding: EdgeInsets.only(top: topPadding),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAvatarStack(),
                  const SizedBox(height: 16),
                  Text(
                    controller.currentUser?.fullName ?? '-',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  _buildRoleBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: controller.currentUser?.profilePhoto != null
                ? ClipOval(
                    child: Image.network(
                      controller.currentUser!.profilePhoto!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar();
                      },
                    ),
                  )
                : _buildInitialsAvatar(),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Text(
        _getRoleLabel(controller.currentUser?.role),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return _buildSection(
      title: 'Akun',
      children: [
        Obx(
          () => _buildMenuItem(
            icon: Icons.person_outline,
            title: 'Informasi Pribadi',
            subtitle: controller.currentUser?.email ?? '-',
            iconColor: Colors.blue,
            onTap: () => Get.to(() => const UserInfoPage()),
          ),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.badge_outlined,
          title: 'Ubah Profile',
          subtitle: 'Edit informasi profile Anda',
          iconColor: const Color.fromARGB(255, 89, 255, 0),
          onTap: () => _navigateToEditProfile(),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.lock_outline,
          title: 'Ubah Password',
          subtitle: 'Tingkatkan keamanan akun',
          iconColor: Colors.orange,
          onTap: () => Get.to(() => const ChangePasswordPage()),
        ),
      ],
    );
  }

  Widget _buildSettingsSection() {
    return _buildSection(
      title: 'Pengaturan',
      children: [
        _buildMenuItem(
          icon: Icons.notifications_none,
          title: 'Notifikasi',
          subtitle: 'Atur preferensi notifikasi Anda',
          iconColor: Colors.purple,
          onTap: () => _showComingSoonNotification('Notifikasi'),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.language_outlined,
          title: 'Bahasa',
          subtitle: 'Indonesia',
          iconColor: Colors.green,
          onTap: () => _showComingSoonNotification('Pengaturan Bahasa'),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _buildSection(
      title: 'Tentang',
      children: [
        FutureBuilder<String>(
          future: _getAppVersion(),
          builder: (context, snapshot) {
            final version = snapshot.data ?? '...';
            return _buildMenuItem(
              icon: Icons.info_outline,
              title: 'Tentang Aplikasi',
              subtitle: 'Versi $version',
              iconColor: Colors.teal,
              onTap: () => _showAboutDialog(),
            );
          },
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.system_update,
          title: 'Cek Pembaruan',
          subtitle: 'Periksa pembaruan aplikasi',
          iconColor: Colors.blue,
          onTap: () => _checkForUpdate(),
        ),
        _buildDivider(),
        _buildMenuItem(
          icon: Icons.privacy_tip_outlined,
          title: 'Kebijakan Privasi',
          subtitle: 'Baca kebijakan privasi kami',
          iconColor: Colors.indigo,
          onTap: () => _showComingSoonNotification('Kebijakan Privasi'),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading ? null : () => _showLogoutDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade500,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: const Size(double.infinity, 52),
            elevation: 2,
          ),
          child: controller.isLoading
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Keluar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildInitialsAvatar() {
    final name = controller.currentUser?.fullName ?? '';
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
            .take(2)
            .join()
        : '?';

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getRoleColor(controller.currentUser?.role),
            _getRoleColor(controller.currentUser?.role).withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey.shade200, thickness: 1),
    );
  }

  void _navigateToEditProfile() {
    final id = controller.currentUser?.id;
    if (id == null) {
      Get.find<NotificationController>().showError(
        'Gagal mendapatkan informasi pengguna',
      );
      return;
    }
    Get.to(
      () => EditUserPage(),
      binding: BindingsBuilder(() {
        UserBinding().dependencies();
        DivisionBinding().dependencies();
      }),
    );
  }

  void _showComingSoonNotification(String feature) {
    Get.find<NotificationController>().showInfo(
      'Fitur $feature akan segera hadir',
    );
  }

  void _showAboutDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: BottomSheetHandle(margin: EdgeInsets.only(bottom: 12)),
                ),
                const Text(
                  'Tentang Aplikasi',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 24),
                _buildAppLogoSection(),
                const SizedBox(height: 24),
                FutureBuilder<String>(
                  future: _getAppVersion(),
                  builder: (context, snapshot) {
                    final buildInfo = snapshot.data ?? '...';
                    return _buildInfoItem(
                      icon: Icons.info_rounded,
                      title: 'Versi Aplikasi',
                      value: 'v$buildInfo',
                    );
                  },
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  icon: Icons.business_rounded,
                  title: 'Dikembangkan oleh',
                  value: 'Tim PKL Diskominfo Badung',
                ),
                const SizedBox(height: 8),
                _buildInfoItem(
                  icon: Icons.calendar_today_rounded,
                  title: 'Tahun Rilis',
                  value: '2025',
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    '© 2025 Tim PKL Diskominfo Badung. Hak cipta dilindungi.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppLogoSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset(
            'assets/logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'SiRapat',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sistem Informasi Rapat',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: BottomSheetHandle(
                    margin: EdgeInsets.only(bottom: 16),
                  ),
                ),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      size: 48,
                      color: Colors.red.shade500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Konfirmasi Keluar',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Apakah Anda yakin ingin keluar dari aplikasi? '
                    'Anda perlu masuk kembali untuk mengakses aplikasi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
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
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          controller.logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Keluar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
    );
  }

  void _checkForUpdate() {
    UpdateDialog.checkAndShowUpdate(
      repoOwner: 'RanggaCasper',
      repoName: 'sirapat-app',
      forceShow: true,
    );
  }
}
