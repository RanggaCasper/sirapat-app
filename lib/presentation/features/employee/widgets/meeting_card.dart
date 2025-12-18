import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/date_formatter.dart';

class MeetingCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final String startTime;
  final String endTime;
  final VoidCallback? onTap;

  const MeetingCard({
    super.key,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLG,
      child: Container(
        padding: AppSpacing.paddingLG,
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusLG,
          boxShadow: AppShadow.card,
        ),
        child: Row(
          children: [
            // Icon Calendar (Kiri)
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month,
                size: 24,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Konten Judul & Tanggal (Tengah)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.event, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormatter.formatToDateTime(date),
                        style: AppTextStyles.body.copyWith(
                          fontSize: 12,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Waktu (Kanan)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  startTime.substring(0, 5), // Menghilangkan detik (09:00)
                  style: AppTextStyles.title.copyWith(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "s/d ${endTime.substring(0, 5)}",
                  style: AppTextStyles.body.copyWith(
                    fontSize: 11,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
