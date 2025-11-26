import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';

class ActionItemMeet extends StatelessWidget {
  final String title;
  final String dueDate;
  final String assignee;

  const ActionItemMeet({
    Key? key,
    required this.title,
    required this.dueDate,
    required this.assignee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Text(
              dueDate,
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text(
              assignee,
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
      ],
    );
  }
}
