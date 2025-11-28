import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class ChatButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ChatButton({Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed ?? () {},
      backgroundColor: AppColors.primaryDark,
      child: const Icon(Icons.chat_bubble),
    );
  }
}
