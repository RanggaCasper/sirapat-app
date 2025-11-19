import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';

/// Widget untuk menampilkan informasi user di header dashboard
class UserHeaderCard extends StatelessWidget {
  final String userName;
  final String userNip;
  final String? userRole;
  final String? userImageUrl;
  final Color? backgroundColor;
  final Color? textColor;

  const UserHeaderCard({
    Key? key,
    required this.userName,
    required this.userNip,
    this.userRole,
    this.userImageUrl,
    this.backgroundColor,
    this.textColor,
  }) : super(key: key);

  Color _getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return Colors.orange;
      case 'master':
        return Colors.purple;
      case 'employee':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final txtColor = textColor ?? Colors.white;

    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.radiusLG,
        boxShadow: AppShadow.md(bgColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hallo, $userName!',
                  style: AppTextStyles.title.copyWith(color: txtColor),
                ),
                SizedBox(height: AppSpacing.xs),
                Text(
                  'Bagaimana kabarmu hari ini?',
                  style: AppTextStyles.body.copyWith(
                    color: txtColor.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.lg),
          Container(
            width: AppIconSize.xxl,
            height: AppIconSize.xxl,
            decoration: BoxDecoration(
              color: txtColor,
              shape: BoxShape.circle,
              border: Border.all(color: txtColor.withOpacity(0.3), width: 3),
            ),
            child: ClipOval(
              child: userImageUrl != null && userImageUrl!.isNotEmpty
                  ? Image.network(
                      userImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildInitialsAvatar(userName, userRole);
                      },
                    )
                  : _buildInitialsAvatar(userName, userRole),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsAvatar(String fullName, String? role) {
    final name = fullName;
    final initials = name.isNotEmpty
        ? name
              .split(' ')
              .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
              .take(2)
              .join()
        : '?';

    final roleColor = _getRoleColor(role);

    return Container(
      width: AppIconSize.xxl,
      height: AppIconSize.xxl,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [roleColor, roleColor.withOpacity(0.7)],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: AppIconSize.lg * 0.6,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
