import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const InfoItem({
    super.key,
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: AppIconSize.md),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: AppColors.textDark, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
