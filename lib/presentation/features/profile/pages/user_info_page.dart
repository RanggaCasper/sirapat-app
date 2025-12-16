import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class UserInfoPage extends GetView<AuthController> {
  const UserInfoPage({super.key});

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
      appBar: AppBar(
        title: const Text('Informasi Pribadi'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        final user = controller.currentUser;
        
        if (user == null) {
          return const Center(child: Text('Data pengguna tidak ditemukan'));
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header dengan Avatar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.primary),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: user.profilePhoto != null
                            ? ClipOval(
                                child: Image.network(
                                  user.profilePhoto!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildInitialsAvatar(
                                      user.fullName,
                                      user.role,
                                    );
                                  },
                                ),
                              )
                            : _buildInitialsAvatar(user.fullName, user.role),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.fullName ?? '-',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Informasi Detail
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.badge_outlined,
                      label: 'NIP',
                      value: user.nip ?? '-',
                      iconColor: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.person_outline,
                      label: 'Username',
                      value: user.username ?? '-',
                      iconColor: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: user.email ?? '-',
                      iconColor: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.phone_outlined,
                      label: 'No. Telepon',
                      value: user.phone ?? '-',
                      iconColor: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.business_outlined,
                      label: 'Divisi',
                      value: user.division?.name ?? 'Belum ada divisi',
                      iconColor: Colors.teal,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildInitialsAvatar(String? fullName, String? role) {
    final name = fullName ?? '';
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
          colors: [_getRoleColor(role), _getRoleColor(role).withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
