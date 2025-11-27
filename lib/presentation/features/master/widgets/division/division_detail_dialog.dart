import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/date_formatter.dart';
import 'package:sirapat_app/domain/entities/division.dart';

/// Detail bottom sheet untuk menampilkan informasi division
class DivisionDetailDialog extends StatelessWidget {
  final Division division;
  final VoidCallback? onEdit;

  const DivisionDetailDialog({Key? key, required this.division, this.onEdit})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: AppSpacing.paddingLG,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.radiusMD,
                  ),
                  child: Icon(
                    Icons.business,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Divisi',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 18,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textMedium,
                ),
              ],
            ),
          ),

          Divider(height: 1, color: AppColors.borderLight),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    'Nama Divisi',
                    division.name,
                    Icons.business_outlined,
                  ),
                  const SizedBox(height: 20),
                  _buildDetailRow(
                    'Deskripsi',
                    division.description ?? 'Tidak ada deskripsi',
                    Icons.description_outlined,
                  ),
                  if (division.createdAt != null) ...[
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Tanggal Dibuat',
                      DateFormatter.formatToDateTime(division.createdAt!),
                      Icons.calendar_today_outlined,
                    ),
                  ],
                  if (division.updatedAt != null) ...[
                    const SizedBox(height: 20),
                    _buildDetailRow(
                      'Terakhir Diperbarui',
                      DateFormatter.formatToDateTime(division.updatedAt!),
                      Icons.update_outlined,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Bottom Actions
          if (onEdit != null)
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                border: Border(
                  top: BorderSide(color: AppColors.borderLight, width: 1),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.radiusMD,
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    label: Text('Edit Divisi', style: AppTextStyles.button),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
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
          Icon(icon, size: 20, color: AppColors.primary),
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
