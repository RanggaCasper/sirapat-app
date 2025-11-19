import 'package:flutter/material.dart';

/// Icon container dengan background color
class IconContainer extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color? backgroundColor;
  final double size;
  final double padding;
  final double borderRadius;

  const IconContainer({
    Key? key,
    required this.icon,
    required this.color,
    this.backgroundColor,
    this.size = 24,
    this.padding = 12,
    this.borderRadius = 12,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? color.withOpacity(0.1);

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}
