import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

/// Utility class for building consistent status chips across the app
class StatusChipBuilder {
  StatusChipBuilder._();

  /// Build a status chip with appropriate color and text based on status
  static Widget buildMeetingStatusChip(String status) {
    final chipData = _getMeetingStatusData(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipData.bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipData.bgColor.withOpacity(0.3)),
      ),
      child: Text(
        chipData.text,
        style: TextStyle(
          color: chipData.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Build a user role chip
  static Widget buildRoleChip(String role) {
    final chipData = _getRoleData(role);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipData.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipData.bgColor),
      ),
      child: Text(
        chipData.text,
        style: TextStyle(
          color: chipData.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static _ChipData _getMeetingStatusData(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return _ChipData(AppColors.info, 'Terjadwal');
      case 'ongoing':
        return _ChipData(AppColors.warning, 'Berlangsung');
      case 'completed':
        return _ChipData(AppColors.success, 'Selesai');
      case 'cancelled':
        return _ChipData(AppColors.error, 'Dibatalkan');
      default:
        return _ChipData(AppColors.accent, status);
    }
  }

  static _ChipData _getRoleData(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return _ChipData(Colors.purple, 'Admin');
      case 'master':
        return _ChipData(Colors.blue, 'Master');
      case 'employee':
        return _ChipData(Colors.green, 'Employee');
      default:
        return _ChipData(Colors.grey, role);
    }
  }
}

class _ChipData {
  final Color bgColor;
  final Color textColor;
  final String text;

  _ChipData(Color color, this.text)
    : bgColor = color,
      textColor = _getDarkerColor(color);

  static Color _getDarkerColor(Color color) {
    // If it's a MaterialColor, use shade900
    if (color is MaterialColor) {
      return color.shade900;
    }
    // Otherwise, darken the color manually
    return Colors.white;
  }
}
