import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/date_formatter.dart';
import 'package:sirapat_app/domain/entities/user.dart';

/// Halaman detail user
class UserDetailPage extends StatelessWidget {
  final User user;

  const UserDetailPage({Key? key, required this.user}) : super(key: key);

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: AppSpacing.paddingXL,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusLG,
                boxShadow: AppShadow.md(_getRoleColor(user.role)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: AppRadius.radiusMD,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.fullName ?? '-',
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getRoleLabel(user.role),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Information Section
            Text(
              'Informasi',
              style: AppTextStyles.heading2.copyWith(
                color: AppColors.textDark,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.badge_outlined,
              label: 'NIP',
              value: user.nip ?? '-',
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.account_circle_outlined,
              label: 'Username',
              value: user.username ?? '-',
              color: AppColors.secondary,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.email_outlined,
              label: 'Email',
              value: user.email ?? '-',
              color: AppColors.accentTeal,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.phone_outlined,
              label: 'Nomor Telepon',
              value: user.phone ?? '-',
              color: AppColors.warning,
            ),

            if (user.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal Dibuat',
                value: DateFormatter.formatStringToDateTime(user.createdAt!),
                color: AppColors.accentOrange,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppRadius.radiusSM,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
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
