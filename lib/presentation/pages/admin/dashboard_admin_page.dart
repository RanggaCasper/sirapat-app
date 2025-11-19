import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'widgets/create_meeting_button.dart';
import 'widgets/admin_bottom_navbar.dart';
import 'package:sirapat_app/presentation/widgets/custom_meeting_card.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kPageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),

              const SizedBox(height: 24),
              CreateMeetingButton(),

              const SizedBox(height: 24),
              const CustomMeetingCard(
                title: 'Rapat\nkoordinasi IT',
                time: 'Hari ini, 14:00',
                status: 'LIVE',
              ),
              const SizedBox(height: 16),

              const CustomMeetingCard(
                title: 'Rapat\nkoordinasi IT',
                time: 'Hari ini, 14:00',
                status: 'LIVE',
              ),
              const SizedBox(height: 16),

              const CustomMeetingCard(
                title: 'Rapat\wkwkwkwkwk IT',
                time: 'Hari ini, 14:00',
                status: 'LIVE',
              ),
              const SizedBox(height: 16),

              const CustomMeetingCard(
                title: 'Rapat\nkoordinasi IT',
                time: 'Hari ini, 14:00',
                status: 'LIVE',
              ),
              const SizedBox(height: 16),

              const CustomMeetingCard(
                title: 'Review\nSistem',
                time: 'Besok, 10:00',
                status: 'Schedule',
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 0),
    );
  }


  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Admin',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.titleDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Dinas Komunikasi & Informatika',
              style: TextStyle(fontSize: 14, color: AppColors.kSubtitleColor),
            ),
          ],
        ),
      ],
    );
  }
}
