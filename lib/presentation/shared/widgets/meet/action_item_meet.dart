import 'package:flutter/material.dart';

class ActionItemMeet extends StatelessWidget {
  final String title;
  final String dueDate;
  final String assignee;

  const ActionItemMeet({
    Key? key,
    required this.title,
    required this.dueDate,
    required this.assignee,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              dueDate,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(width: 16),
            Text(
              assignee,
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ],
    );
  }
}
