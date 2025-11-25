import 'package:flutter/material.dart';

class MeetingTitle extends StatelessWidget {
  final String? title;

  const MeetingTitle({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      title ?? 'Rapat\nKoordinasi IT',
      style: const TextStyle(
        color: Color(0xFF1E3A8A),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }
}
