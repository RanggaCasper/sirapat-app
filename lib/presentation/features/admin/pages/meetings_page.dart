import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/pagination_controls.dart';
import 'package:sirapat_app/presentation/shared/widgets/empty_state.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';

/// Meeting management section untuk Admin Dashboard
class MeetingsPage extends GetView<MeetingController> {
  const MeetingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.searchMeetings,
              decoration: InputDecoration(
                hintText: 'Cari rapat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  return controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchMeetings('');
                          },
                        )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),

          // Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingObs.value) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: 6,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: const MeetingCardSkeleton(),
                  ),
                );
              }

              if (controller.meetings.isEmpty &&
                  controller.searchQuery.value.isEmpty) {
                return EmptyState(
                  icon: Icons.event_note,
                  title: 'Belum ada rapat',
                  message: 'Tap tombol + untuk menambah rapat',
                  buttonText: 'Tambah Rapat',
                  onButtonPressed: () => Get.toNamed('/admin-create-meeting'),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchMeetings,
                child: Column(
                  children: [
                    Expanded(
                      child: controller.meetings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Rapat tidak ditemukan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Coba kata kunci lain',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: controller.meetings.length,
                              itemBuilder: (context, index) {
                                final meeting = controller.meetings[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: MeetingCard(
                                    title: meeting.title,
                                    date: DateTime.parse(meeting.date),
                                    onTap: () {
                                      Get.toNamed(
                                        '/admin-meeting-detail',
                                        arguments: meeting,
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),

                    // Pagination controls at the bottom (always show)
                    if (controller.paginationMeta.value != null)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: PaginationControls(
                          meta: controller.paginationMeta.value!,
                          onPrevious: controller.previousPage,
                          onNext: controller.nextPage,
                          onPageSelect: controller.goToPage,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        // Only show FAB when pagination exists
        if (controller.paginationMeta.value == null) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 90),
          child: FloatingActionButton(
            onPressed: () => Get.toNamed('/admin-create-meeting'),
            tooltip: 'Tambah Rapat',
            child: const Icon(Icons.add),
          ),
        );
      }),
    );
  }
}
