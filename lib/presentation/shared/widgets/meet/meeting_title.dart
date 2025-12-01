import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class MeetingTitle extends StatelessWidget {
  final String? title;

  const MeetingTitle({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? 'Rapat\nKoordinasi IT',
      style: TextStyle(
        color: AppColors.primaryDark,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }
}
