import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class ChatButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ChatButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: AppColors.primaryDark,
      child: const Icon(Icons.chat_bubble),
    );
  }
}
