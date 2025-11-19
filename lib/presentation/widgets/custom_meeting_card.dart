import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class CustomMeetingCard extends StatelessWidget {
  final String title;
  final String? time;
  final String? status;

  const CustomMeetingCard({
    Key? key,
    required this.title,
    this.time,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.kBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.blueGrey.shade50.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.titleDark,
                    height: 1.3,
                  ),
                ),
                if (time != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    time!,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.kSubtitleColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Badge Status
          if (status != null) _buildBadge(status!),
        ],
      ),
    );
  }

  Widget _buildBadge(String status) {
    Color badgeColor = status == 'LIVE'
        ? AppColors.kLiveBadgeColor
        : AppColors.kScheduleBadgeColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
