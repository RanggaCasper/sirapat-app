import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';

/// Widget untuk card statistik dengan icon di samping
class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.accentTeal;
    final icColor = iconColor ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLG,
      child: Container(
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.radiusLG,
          boxShadow: AppShadow.md(bgColor),
        ),
        child: Row(
          children: [
            Container(
              width: AppIconSize.xxl - 4,
              height: AppIconSize.xxl - 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: AppRadius.radiusMD,
              ),
              child: Icon(icon, color: icColor, size: AppIconSize.lg),
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: icColor.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    value,
                    style: AppTextStyles.heading1.copyWith(
                      color: icColor,
                      fontSize: 28,
                    ),
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
