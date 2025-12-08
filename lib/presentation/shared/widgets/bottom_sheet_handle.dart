import 'package:flutter/material.dart';

/// Global widget for bottom sheet drag handle indicator
/// Provides visual affordance that bottom sheets can be dismissed by dragging
class BottomSheetHandle extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const BottomSheetHandle({
    super.key,
    this.width = 40,
    this.height = 4,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
