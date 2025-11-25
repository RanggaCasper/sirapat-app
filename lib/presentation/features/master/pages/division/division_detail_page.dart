import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/domain/entities/division.dart';

/// Halaman detail division
class DivisionDetailPage extends StatelessWidget {
  final Division division;

  const DivisionDetailPage({Key? key, required this.division})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Divisi'),
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
                boxShadow: AppShadow.md(AppColors.primary),
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
                      Icons.business,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    division.name,
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  if (division.description != null &&
                      division.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      division.description!,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
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
              icon: Icons.business_outlined,
              label: 'Nama Divisi',
              value: division.name,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),

            _buildInfoCard(
              icon: Icons.description_outlined,
              label: 'Deskripsi',
              value: division.description ?? 'Tidak ada deskripsi',
              color: AppColors.secondary,
            ),

            if (division.createdAt != null) ...[
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal Dibuat',
                value: _formatDate(division.createdAt!),
                color: AppColors.accentTeal,
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

  String _formatDate(DateTime date) {
    try {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return date.toString();
    }
  }
}
