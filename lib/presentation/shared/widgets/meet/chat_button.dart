import 'package:flutter/material.dart';

class ChatButton extends StatelessWidget {
  const ChatButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: const Color(0xFF1E3A8A),
      child: const Icon(Icons.chat_bubble),
    );
  }
}
