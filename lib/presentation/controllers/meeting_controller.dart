import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/app/util/form_error_handler.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/entities/pagination.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meetings_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meeting_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_passcode_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/create_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/update_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/delete_meeting_usecase.dart';
import 'package:sirapat_app/domain/usecases/meeting/join_meeting_by_code_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';
import 'package:sirapat_app/presentation/shared/widgets/bottom_sheet_handle.dart';
import 'package:sirapat_app/presentation/shared/widgets/passcode_qr_bottom_sheet.dart';

class MeetingController extends GetxController {
  final GetMeetingsUseCase _getMeetingsUseCase;
  final GetMeetingByIdUseCase _getMeetingByIdUseCase;
  final CreateMeetingUseCase _createMeetingUseCase;
  final UpdateMeetingUseCase _updateMeetingUseCase;
  final DeleteMeetingUseCase _deleteMeetingUseCase;
  final JoinMeetingByCodeUseCase _joinMeetingByCodeUseCase;
  final GetPasscodeByIdUseCase _getPasscodeByIdUseCase;

  MeetingController(
    this._getMeetingsUseCase,
    this._getMeetingByIdUseCase,
    this._createMeetingUseCase,
    this._updateMeetingUseCase,
    this._deleteMeetingUseCase,
    this._joinMeetingByCodeUseCase,
    this._getPasscodeByIdUseCase,
  );

  // Observable lists
  final RxList<Meeting> meetings = <Meeting>[].obs;
  final RxList<Meeting> _allMeetings = <Meeting>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Form controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Selected meeting for edit
  final Rx<Meeting?> selectedMeeting = Rx<Meeting?>(null);
  final RxString selectedStatus = 'scheduled'.obs;
  final RxBool hasPasscode = false.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;
  bool get isEditMode => selectedMeeting.value != null;

  // Notification helper
  NotificationController get _notif => Get.find<NotificationController>();

  // Status options
  final List<Map<String, String>> statusOptions = [
    {'value': 'scheduled', 'label': 'Terjadwal'},
    {'value': 'ongoing', 'label': 'Berlangsung'},
    {'value': 'completed', 'label': 'Selesai'},
    {'value': 'cancelled', 'label': 'Dibatalkan'},
  ];

  @override
  void onInit() {
    super.onInit();
    // Wait for next frame to ensure AuthController is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchMeetings();
    });
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    agendaController.dispose();
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Fetch all meetings from API (only once)
  Future<void> fetchMeetings({
    int page = 1,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      debugPrint('[MeetingController] Fetching meetings from API...');

      // Fetch all data from API
      final result = await _getMeetingsUseCase.execute();
      _allMeetings.value = result;

      debugPrint('[MeetingController] Fetched ${result.length} meetings');
      debugPrint('[MeetingController] All meetings: ${_allMeetings.length}');

      // After fetching, apply pagination on client side
      _applyPagination(page: page, perPage: perPage);

      debugPrint(
        '[MeetingController] Meetings after pagination: ${meetings.length}',
      );
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in fetchMeetings: ${e.message}',
      );
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[MeetingController] Exception in fetchMeetings: $e');
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingObs.value = false;
    }
  }

  // Apply client-side pagination and search filter
  void _applyPagination({int page = 1, int perPage = 10}) {
    // Apply search filter
    final filteredData = searchQuery.value.isEmpty
        ? _allMeetings
        : _allMeetings.where((meeting) {
            final query = searchQuery.value.toLowerCase();
            final title = meeting.title.toLowerCase();
            final description = (meeting.description ?? '').toLowerCase();
            final location = (meeting.location ?? '').toLowerCase();
            final agenda = (meeting.agenda ?? '').toLowerCase();
            return title.contains(query) ||
                description.contains(query) ||
                location.contains(query) ||
                agenda.contains(query);
          }).toList();

    // Calculate pagination
    final totalItems = filteredData.length;
    final lastPage = totalItems > 0 ? (totalItems / perPage).ceil() : 1;
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, totalItems);

    // Get items for current page
    meetings.value = totalItems > 0
        ? filteredData.sublist(startIndex.clamp(0, totalItems), endIndex)
        : [];

    // Set pagination meta (always show even if 1 page)
    paginationMeta.value = PaginationMeta(
      currentPage: page,
      perPage: perPage,
      total: totalItems,
      lastPage: lastPage,
    );
  }

  // Search meetings (client-side filter)
  void searchMeetings(String query) {
    searchQuery.value = query;
    _applyPagination(
      page: 1,
      perPage: AppConstants.defaultPageSize,
    ); // Reset to first page when searching
  }

  // Navigate to specific page (client-side)
  void goToPage(int page) {
    if (paginationMeta.value != null) {
      _applyPagination(page: page, perPage: paginationMeta.value!.perPage);
    }
  }

  // Go to next page
  void nextPage() {
    if (paginationMeta.value?.hasNextPage ?? false) {
      goToPage(paginationMeta.value!.nextPage);
    }
  }

  // Go to previous page
  void previousPage() {
    if (paginationMeta.value?.hasPreviousPage ?? false) {
      goToPage(paginationMeta.value!.previousPage);
    }
  }

  // Get meeting by ID
  Future<void> fetchMeetingById(int id) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      debugPrint('[MeetingController] Fetching meeting with ID: $id');

      // First try to get from already loaded meetings
      final cachedMeeting = _allMeetings.firstWhereOrNull((m) => m.id == id);
      if (cachedMeeting != null) {
        debugPrint(
          '[MeetingController] Found meeting in cache: ${cachedMeeting.title}',
        );
        selectedMeeting.value = cachedMeeting;
        _populateForm(cachedMeeting);
        isLoadingActionObs.value = false;
        return;
      }

      // If not in cache, try API call
      debugPrint(
        '[MeetingController] Meeting not in cache, fetching from API...',
      );
      final meeting = await _getMeetingByIdUseCase.execute(id);
      debugPrint(
        '[MeetingController] Meeting fetched from API: ${meeting.title}',
      );
      selectedMeeting.value = meeting;
      _populateForm(meeting);
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in fetchMeetingById: ${e.message}',
      );
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[MeetingController] Exception in fetchMeetingById: $e');
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Create new meeting
  Future<void> createMeeting() async {
    if (!_validateForm(isEdit: false)) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      final meeting = await _createMeetingUseCase.execute(
        CreateMeetingParams(
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          location: locationController.text.trim().isEmpty
              ? null
              : locationController.text.trim(),
          agenda: agendaController.text.trim().isEmpty
              ? null
              : agendaController.text.trim(),
          date: dateController.text.trim(),
          startTime: startTimeController.text.trim(),
          endTime: endTimeController.text.trim(),
          status: selectedStatus.value,
          hasPasscode: hasPasscode.value,
        ),
      );

      // Add to local cache immediately
      _allMeetings.insert(0, meeting);
      _applyPagination(
        page: 1, // Go to first page to show the new meeting
        perPage: paginationMeta.value?.perPage ?? AppConstants.defaultPageSize,
      );

      // Show success toast
      _notif.showSuccess('Rapat "${meeting.title}" berhasil ditambahkan');

      clearForm();

      // Show passcode bottom sheet if meeting has passcode
      if (meeting.passcode != null && meeting.passcode!.isNotEmpty) {
        showPasscodeQrBottomSheet(
          meetingId: meeting.id,
          passcode: meeting.passcode!,
          meetingTitle: meeting.title,
          meetingDate: meeting.date,
          meetingStartTime: meeting.startTime,
          meetingEndTime: meeting.endTime,
          meetingUuid: meeting.uuid,
        );
      }

      // Refresh from API in background
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        fetchMeetings();
      });
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in createMeeting: ${e.message}',
      );
      debugPrint('[MeetingController] Errors: ${e.errors}');

      _errorMessage.value = e.message;

      // Use global form error handler
      final errors = FormErrorHandler.handleApiException(e);
      fieldErrors.addAll(errors);

      // Fallback error if no field errors
      if (errors.isEmpty) {
        fieldErrors['title'] = e.message;
      }
    } catch (e) {
      debugPrint('[MeetingController] Exception in createMeeting: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal menambah rapat: ${e.toString().replaceAll('Exception: ', '')}';
      fieldErrors['title'] = errorMsg;
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Update existing meeting
  Future<void> updateMeeting(String meetingId) async {
    if (selectedMeeting.value == null) return;
    if (!_validateForm(isEdit: true)) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      final meeting = await _updateMeetingUseCase.execute(
        UpdateMeetingParams(
          id: selectedMeeting.value!.id,
          title: titleController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
          location: locationController.text.trim().isEmpty
              ? null
              : locationController.text.trim(),
          agenda: agendaController.text.trim().isEmpty
              ? null
              : agendaController.text.trim(),
          date: dateController.text.trim(),
          startTime: startTimeController.text.trim(),
          endTime: endTimeController.text.trim(),
          status: selectedStatus.value,
        ),
      );

      // Update local cache immediately to show updated data
      final index = _allMeetings.indexWhere((m) => m.id == meeting.id);
      if (index != -1) {
        _allMeetings[index] = meeting;
        _applyPagination(
          page: paginationMeta.value?.currentPage ?? 1,
          perPage:
              paginationMeta.value?.perPage ?? AppConstants.defaultPageSize,
        );
      }

      // Update selectedMeeting so detail page shows updated data
      selectedMeeting.value = meeting;

      _notif.showSuccess('Rapat "${meeting.title}" berhasil diperbarui');

      clearForm();

      // Close edit page and detail page, return to meeting list
      Get.back(); // Close edit page
      Get.back(); // Close detail page

      // Refresh from API in background without blocking UI
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        fetchMeetings();
      });
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in updateMeeting: ${e.message}',
      );
      debugPrint('[MeetingController] Errors: ${e.errors}');

      _errorMessage.value = e.message;

      // Use global form error handler
      final errors = FormErrorHandler.handleApiException(e);
      fieldErrors.addAll(errors);

      // Fallback error if no field errors
      if (errors.isEmpty) {
        fieldErrors['title'] = e.message;
      }
    } catch (e) {
      debugPrint('[MeetingController] Exception in updateMeeting: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal memperbarui rapat: ${e.toString().replaceAll('Exception: ', '')}';
      fieldErrors['title'] = errorMsg;
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Delete meeting
  Future<void> deleteMeeting(int id) async {
    final meeting = meetings.firstWhereOrNull((m) => m.id == id);
    if (meeting == null) {
      _notif.showError("Rapat tidak ditemukan.");
      return;
    }

    final meetingTitle = meeting.title;
    debugPrint(
      '[MeetingController] Prompting delete confirmation for meeting ID: $id',
    );

    final confirmed = await Get.bottomSheet<bool>(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: BottomSheetHandle(margin: EdgeInsets.only(bottom: 16)),
            ),
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin menghapus "$meetingTitle"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(Get.context!).pop(false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(Get.context!).pop(true),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Hapus'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );

    if (confirmed != true) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      await _deleteMeetingUseCase.execute(id);

      // Remove from local cache immediately
      _allMeetings.removeWhere((m) => m.id == id);
      meetings.removeWhere((m) => m.id == id);

      // Reapply pagination to update UI
      _applyPagination(
        page: paginationMeta.value?.currentPage ?? 1,
        perPage: paginationMeta.value?.perPage ?? AppConstants.defaultPageSize,
      );

      _notif.showSuccess('Rapat "$meetingTitle" berhasil dihapus');

      // Navigate back to list if we're in detail page
      if (Get.currentRoute.contains('detail')) {
        Get.back();
      }

      // Refresh from API in background
      Future.delayed(const Duration(milliseconds: 200)).then((_) {
        fetchMeetings();
      });
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in deleteMeeting: ${e.message}',
      );

      _errorMessage.value = e.message;

      _notif.showError('Gagal menghapus rapat: ${e.message}');
    } catch (e) {
      debugPrint('[MeetingController] Exception in deleteMeeting: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal menghapus rapat: ${e.toString()}');
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Prepare for edit
  void prepareEdit(Meeting meeting) {
    selectedMeeting.value = meeting;
    _populateForm(meeting);
  }

  void _populateForm(Meeting meeting) {
    titleController.text = meeting.title;
    descriptionController.text = meeting.description ?? '';
    locationController.text = meeting.location ?? '';
    agendaController.text = meeting.agenda ?? '';
    dateController.text = meeting.date;
    // Format waktu dari HH:MM:SS ke HH:MM
    startTimeController.text = _formatTimeToHHMM(meeting.startTime);
    endTimeController.text = _formatTimeToHHMM(meeting.endTime);
    selectedStatus.value = meeting.status;
  }

  // Helper method to format time from HH:MM:SS to HH:MM
  String _formatTimeToHHMM(String time) {
    if (time.isEmpty) return '';
    // Jika sudah format HH:MM, return as is
    if (time.length == 5 && time.contains(':')) return time;
    // Jika format HH:MM:SS, ambil HH:MM saja
    if (time.contains(':')) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
      }
    }
    return time;
  }

  // Clear form
  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    agendaController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    selectedMeeting.value = null;
    selectedStatus.value = 'scheduled';
    hasPasscode.value = false;
    FormErrorHandler.clearAllFieldErrors(fieldErrors);
    _errorMessage.value = '';
  }

  // Validate form
  bool _validateForm({required bool isEdit}) {
    FormErrorHandler.clearAllFieldErrors(fieldErrors);

    if (titleController.text.trim().isEmpty) {
      fieldErrors['title'] = 'Judul rapat wajib diisi';
      return false;
    }

    if (dateController.text.trim().isEmpty) {
      fieldErrors['date'] = 'Tanggal rapat wajib diisi';
      return false;
    }

    if (startTimeController.text.trim().isEmpty) {
      fieldErrors['start_time'] = 'Waktu mulai wajib diisi';
      return false;
    }

    if (endTimeController.text.trim().isEmpty) {
      fieldErrors['end_time'] = 'Waktu selesai wajib diisi';
      return false;
    }

    // Validate time range
    if (!_validateTimeRange()) {
      fieldErrors['end_time'] =
          'Waktu selesai harus lebih besar dari waktu mulai';
      return false;
    }

    return true;
  }

  bool _validateTimeRange() {
    try {
      final start = _parseTime(startTimeController.text.trim());
      final end = _parseTime(endTimeController.text.trim());
      return end.isAfter(start);
    } catch (e) {
      return false;
    }
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hour, minute);
  }

  // Get field error
  String? getFieldError(String fieldName) {
    return FormErrorHandler.getFieldError(fieldErrors, fieldName);
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    FormErrorHandler.clearFieldError(fieldErrors, fieldName);
  }

  // Get status label
  String getStatusLabel(String status) {
    return statusOptions.firstWhere(
      (s) => s['value'] == status,
      orElse: () => {'value': status, 'label': status},
    )['label']!;
  }

  // Filter meetings by status
  List<Meeting> getMeetingsByStatus(String status) {
    return _allMeetings.where((m) => m.status == status).toList();
  }

  // Get meetings count by status
  int getMeetingsCountByStatus(String status) {
    return _allMeetings.where((m) => m.status == status).length;
  }

  // Join meeting by code
  Future<void> joinMeetingByCode(String meetingCode) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      if (meetingCode.trim().isEmpty) {
        fieldErrors['meeting_code'] = 'Silakan masukkan kode rapat';
        isLoadingActionObs.value = false;
        return;
      }

      debugPrint('[MeetingController] Joining meeting with code: $meetingCode');

      final meeting = await _joinMeetingByCodeUseCase.execute(
        meetingCode.trim(),
      );

      if (meeting != null) {
        _notif.showSuccess('Berhasil mengikuti rapat "${meeting.title}"');
        debugPrint(
          '[MeetingController] Successfully joined meeting: ${meeting.title}',
        );

        // Refresh meetings list
        await fetchMeetings();
      } else {
        fieldErrors['meeting_code'] = 'Gagal mengikuti rapat';
      }
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in joinMeetingByCode: ${e.message}',
      );
      _errorMessage.value = e.message;
      fieldErrors['meeting_code'] = e.message;
    } catch (e) {
      debugPrint('[MeetingController] Exception in joinMeetingByCode: $e');
      _errorMessage.value = 'Gagal mengikuti rapat';
      fieldErrors['meeting_code'] = 'Gagal mengikuti rapat';
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Get meeting passcode
  Future<String?> getMeetingPasscodeById(int id) async {
    try {
      final passcode = await _getPasscodeByIdUseCase.execute(id);

      return passcode;
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in getMeetingPasscodeById: ${e.message}',
      );
      // Don't show error notification - passcode might not be available yet
      return null;
    } catch (e) {
      debugPrint('[MeetingController] Exception in getMeetingPasscodeById: $e');
      // Don't show error notification - handle silently
      return null;
    }
  }
}
