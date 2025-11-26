import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_controller.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';

class HistoryMeetPage extends StatefulWidget {
  const HistoryMeetPage({Key? key}) : super(key: key);

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
      appBar: _buildAppBar(),
      body: SafeArea(child: _buildHomeSection()),
    );
  }

  Widget _buildHomeSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildSearchBar(), _buildMeetingList()],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: Text(
        'History Rapat',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: AppElevation.sm,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Cari rapat...',
            hintStyle: TextStyle(color: AppColors.textLight, fontSize: 14),
            prefixIcon: Icon(
              Icons.search,
              color: AppColors.textLight,
              size: AppIconSize.sm,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeetingList() {
    final meetingController = Get.find<MeetingController>();
    return Obx(() {
      if (meetingController.isLoadingObs.value) {
        return Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      final meetings = meetingController.meetings;
      if (meetings.isEmpty) {
        return _buildEmptyMeetingState();
      }
      return ListView.builder(
        padding: EdgeInsets.all(AppSpacing.lg),
        itemCount: meetings.length,
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < meetings.length - 1 ? AppSpacing.md : 0,
            ),
            child: _buildMeetingCard(meeting),
          );
        },
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      );
    });
  }

  Widget _buildMeetingCard(dynamic meeting) {
    final title = meeting is Map
        ? (meeting['title'] ?? '')
        : (meeting?.title ?? '');
    final date = meeting is Map
        ? (meeting['date'] ?? '')
        : (meeting?.date ?? '');
    final startTime = meeting is Map
        ? (meeting['start_time'] ?? '')
        : (meeting?.startTime ?? '');

    return GestureDetector(
      onTap: () => _onMeetingCardTapped(meeting),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: AppRadius.radiusMD,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: AppElevation.lg,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTitle(title),
            const SizedBox(height: AppSpacing.sm),
            _buildCardInfo(date, startTime),
            const SizedBox(height: AppSpacing.md),
            _buildCardFooter(meeting),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMeetingState() {
    return Padding(
      padding: AppSpacing.paddingLG,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada rapat',
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _onMeetingCardTapped(dynamic meeting) {
    // Navigate to meeting detail page with meeting ID
    final id = meeting is Map ? meeting['id'] : meeting.id;
    if (id == null) {
      Get.snackbar(
        'Error',
        'ID rapat tidak ditemukan',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.to(
      DetailMeetPage(meetingId: id),
      transition: Transition.rightToLeft,
      arguments: id,
    );
  }

  Widget _buildCardTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildCardInfo(String date, String time) {
    return Row(
      children: [
        Icon(
          Icons.calendar_today,
          size: AppIconSize.sm,
          color: AppColors.textLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(date, style: TextStyle(fontSize: 13, color: AppColors.textLight)),
        const SizedBox(width: AppSpacing.lg),
        Icon(
          Icons.access_time,
          size: AppIconSize.sm,
          color: AppColors.textLight,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(time, style: TextStyle(fontSize: 13, color: AppColors.textLight)),
      ],
    );
  }

  Widget _buildCardFooter(dynamic meeting) {
    final id = meeting is Map ? (meeting['id'] ?? 0) : (meeting?.id ?? 0);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [_buildParticipantInfo(id), _buildViewNotesButton(meeting)],
    );
  }

  Widget _buildParticipantInfo(dynamic count) {
    return Row(
      children: [
        Icon(Icons.people, size: AppIconSize.sm, color: AppColors.textLight),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'ID: $count',
          style: TextStyle(fontSize: 13, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildViewNotesButton(dynamic meeting) {
    return ElevatedButton.icon(
      onPressed: () => _onMeetingCardTapped(meeting),
      icon: const Icon(Icons.description, size: 16),
      label: const Text(
        'Lihat Notulensi',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: AppElevation.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}
