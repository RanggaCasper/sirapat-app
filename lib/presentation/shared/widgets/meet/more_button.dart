import 'package:flutter/material.dart';
import 'package:sirapat_app/app/config/app_colors.dart';

class MoreButton extends StatelessWidget {
  const MoreButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.more_vert, color: AppColors.primaryDark),
      onPressed: () {},
    );
  }
}
