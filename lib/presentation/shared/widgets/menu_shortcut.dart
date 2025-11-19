import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';

/// Widget untuk menu shortcut di dashboard
class MenuShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? iconColor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MenuShortcut({
    Key? key,
    required this.icon,
    required this.label,
    this.iconColor,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final icColor = iconColor ?? Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radiusLG,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: AppIconSize.xxl,
            height: AppIconSize.xxl,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: AppRadius.radiusLG,
              boxShadow: AppShadow.md(bgColor),
            ),
            child: Icon(icon, color: icColor, size: AppIconSize.lg),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
