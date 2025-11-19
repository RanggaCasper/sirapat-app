import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/widgets/custom_meeting_card.dart';
import 'package:sirapat_app/presentation/pages/admin/widgets/admin_bottom_navbar.dart';

import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
// import 'package:sirapat_app/domain/entities/meeting.dart';

class MeetingListPage extends GetView<MeetingController> {
  const MeetingListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(
                "Kelola Rapat",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titleDark,
                ),
              ),

              const SizedBox(height: 8),
              Container(height: 1, color: Colors.grey.shade300),

              const SizedBox(height: 20),

              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _filterButton("Aktif", 0),
                    const SizedBox(width: 30),
                    _filterButton("Terjadwal", 1),
                    const SizedBox(width: 30),
                    _filterButton("Selesai", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final meetings = controller.filteredMeetings;

                  if (meetings.isEmpty) {
                    return const Center(child: Text("Tidak ada data"));
                  }

                  return ListView.separated(
                    itemCount: meetings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final m = meetings[i];

                      return CustomMeetingCard(
                        title: m.title,
                        time: "${m.startTime} - ${m.endTime} |",
                        status: m.status,
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: const AdminBottomNavbar(currentIndex: 2),
    );
  }

  Widget _filterButton(String text, int index) {
    return Obx(() {
      final selected = controller.selectedFilter.value == index;

      return GestureDetector(
        onTap: () => controller.selectedFilter.value = index,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.titleDark : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black54,
              fontSize: 13,
            ),
          ),
        ),
      );
    });
  }
}
