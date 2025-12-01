import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: AppColors.textMedium, height: 1.6),
    );
  }
}
