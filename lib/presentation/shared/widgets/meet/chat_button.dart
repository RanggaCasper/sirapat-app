import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.primaryDark,
      child: const Icon(Icons.chat_bubble),
    );
  }
}
