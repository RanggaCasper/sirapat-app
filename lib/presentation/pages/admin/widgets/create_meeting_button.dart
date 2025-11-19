import 'package:flutter/material.dart';
import '../meeting/create_edit_meet_page.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class CreateMeetingButton extends StatelessWidget {
  const CreateMeetingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateEditMeetingPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.kLightBlueBg,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '+ Buat Rapat Baru',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.titleDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Mulai rapat dan undang\npeserta dari berbagai\norganisasi',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.kSubtitleColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 16),
            Icon(
              Icons.video_call_rounded,
              color: AppColors.titleDark,
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
