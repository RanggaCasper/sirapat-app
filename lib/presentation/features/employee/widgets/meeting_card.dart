import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/app/util/date_formatter.dart';

class MeetingCard extends StatelessWidget {
  final String title;
  final DateTime date;
  final VoidCallback? onTap;

  const MeetingCard({
    super.key,
    required this.title,
    required this.date,
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
            // Icon Calendar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.calendar_month,
                size: 28,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title.copyWith(
                      fontSize: AppTextStyles.body.fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: AppIconSize.sm,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        DateFormatter.formatToDateTime(date),
                        style: AppTextStyles.body.copyWith(
                          fontSize: AppTextStyles.caption.fontSize,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
