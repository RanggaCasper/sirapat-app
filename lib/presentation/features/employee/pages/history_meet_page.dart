import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/skeleton_loader.dart';
import 'package:sirapat_app/presentation/shared/widgets/pagination_controls.dart';
import 'package:sirapat_app/presentation/features/employee/widgets/meeting_card.dart';

class HistoryMeetPage extends StatefulWidget {
  const HistoryMeetPage({super.key});

  @override
  State<HistoryMeetPage> createState() => _HistoryMeetPageState();
}

class _HistoryMeetPageState extends State<HistoryMeetPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize bindings
    if (!Get.isRegistered<MeetingController>()) {
      MeetingBinding().dependencies();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final meetingController = Get.find<MeetingController>();
    meetingController.searchMeetings(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildMeetingList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final meetingController = Get.find<MeetingController>();
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Cari rapat...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Obx(() {
            return meetingController.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
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
    );
  }

  Widget _buildMeetingList() {
    final meetingController = Get.find<MeetingController>();
    return Obx(() {
      if (meetingController.isLoadingObs.value) {
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          itemCount: 5,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: const MeetingCardSkeleton(),
          ),
        );
      }

      if (meetingController.meetings.isEmpty &&
          meetingController.searchQuery.value.isEmpty) {
        return _buildEmptyMeetingState();
      }

      return RefreshIndicator(
        onRefresh: meetingController.fetchMeetings,
        child: Column(
          children: [
            Expanded(
              child: meetingController.meetings.isEmpty
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
                      itemCount: meetingController.meetings.length,
                      itemBuilder: (context, index) {
                        final meeting = meetingController.meetings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: MeetingCard(
                            title: meeting.title,
                            date: DateTime.parse(meeting.date),
                            onTap: () {
                              Get.to(
                                DetailMeetPage(meetingId: meeting.id),
                                transition: Transition.rightToLeft,
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),

            // Pagination controls at the bottom (always show)
            if (meetingController.paginationMeta.value != null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: PaginationControls(
                  meta: meetingController.paginationMeta.value!,
                  onPrevious: meetingController.previousPage,
                  onNext: meetingController.nextPage,
                  onPageSelect: meetingController.goToPage,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildEmptyMeetingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Belum ada rapat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat rapat Anda akan muncul di sini',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
