import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'summary_header.dart';
import 'summary_description.dart';
import 'section_title.dart';
import 'bullet_point.dart';

class MeetingSummaryCard extends StatelessWidget {
  final Meeting? meeting;
  final bool isLoading;

  const MeetingSummaryCard({Key? key, this.meeting, this.isLoading = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusMD,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: AppElevation.lg,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryDark),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppRadius.radiusMD,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: AppElevation.lg,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SummaryHeader(),
          const SizedBox(height: AppSpacing.lg),
          SummaryDescription(description: meeting?.description),
          const SizedBox(height: AppSpacing.lg),
          const SectionTitle(title: '📌 Agenda'),
          const SizedBox(height: AppSpacing.sm),
          BulletPoint(text: meeting?.agenda ?? 'Tidak ada agenda'),
          if (meeting?.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: AppSpacing.lg),
            const SectionTitle(title: '📝 Detail Tambahan'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              meeting!.description!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
