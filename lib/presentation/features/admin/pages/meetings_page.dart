import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';
import 'package:sirapat_app/presentation/shared/widgets/pagination_controls.dart';

class AllMeetingsPage extends StatelessWidget {
  const AllMeetingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MeetingController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Semua Rapat'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Get.toNamed('/admin-create-meeting'),
            tooltip: 'Tambah Rapat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: AppSpacing.paddingLG,
            color: Colors.white,
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: 'Cari rapat...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() {
                  return controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.searchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink();
                }),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderLight),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                controller.searchQuery.value = value;
              },
            ),
          ),

          // Meeting List
          Expanded(
            child: Obx(() {
              if (controller.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final meetings = controller.meetings;

              if (meetings.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchMeetings(),
                child: ListView.builder(
                  padding: AppSpacing.paddingLG,
                  itemCount: meetings.length,
                  itemBuilder: (context, index) {
                    final meeting = meetings[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: MeetingCard(
                        title: meeting.title,
                        date: DateTime.parse(meeting.date),
                        onTap: () => _onMeetingCardTapped(meeting),
                      ),
                    );
                  },
                ),
              );
            }),
          ),

          // Pagination
          Obx(() {
            final paginationMeta = controller.paginationMeta.value;
            if (paginationMeta == null) return const SizedBox.shrink();

            return Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: PaginationControls(
                meta: paginationMeta,
                onPrevious: paginationMeta.currentPage > 1
                    ? () => controller.fetchMeetings(
                        page: paginationMeta.currentPage - 1,
                      )
                    : null,
                onNext: paginationMeta.currentPage < paginationMeta.lastPage
                    ? () => controller.fetchMeetings(
                        page: paginationMeta.currentPage + 1,
                      )
                    : null,
                onPageSelect: (page) => controller.fetchMeetings(page: page),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: AppColors.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Belum ada rapat',
            style: AppTextStyles.subtitle.copyWith(color: AppColors.secondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ketuk tombol + untuk membuat rapat baru',
            style: AppTextStyles.body.copyWith(
              color: AppColors.secondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _onMeetingCardTapped(dynamic meeting) {
    final id = meeting is Map ? meeting['id'] : meeting.id;
    if (id == null) {
      Get.snackbar(
        'Error',
        'ID rapat tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Navigate to meeting detail
    // Get.toNamed('/meeting-detail', arguments: id);
  }
}
