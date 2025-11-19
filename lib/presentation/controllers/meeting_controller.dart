import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';
import 'package:sirapat_app/domain/usecases/meeting/get_meetings_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class MeetingController extends GetxController {
  final GetMeetingsUseCase _getMeetingsUseCase;

  MeetingController(this._getMeetingsUseCase);

  // Observables
  final RxList<Meeting> meetings = <Meeting>[].obs;
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Selected meeting for detail/edit
  final Rx<Meeting?> selectedMeeting = Rx<Meeting?>(null);

  // Filters: 0=ongoing, 1=scheduled, 2=completed
  final RxInt selectedFilter = 0.obs;

  // Form input controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController agendaController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;

  // Notif helper
  NotificationController get _notif => Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    fetchMeetings();
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
    super.onClose();
  }

  Future<void> fetchMeetings() async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      final meetingList = await _getMeetingsUseCase.execute();
      meetings.value = meetingList;
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

  Future<void> fetchMeetingById(Meeting meeting) async {
    selectedMeeting.value = meeting;

    // Fill form
    titleController.text = meeting.title;
    descriptionController.text = meeting.description ?? '';
    locationController.text = meeting.location ?? '';
    agendaController.text = meeting.agenda ?? '';
    dateController.text = meeting.date;
    startTimeController.text = meeting.startTime;
    endTimeController.text = meeting.endTime;
  }

  List<Meeting> get filteredMeetings {
    return meetings.where((m) {
      switch (selectedFilter.value) {
        case 0:
          return m.status == 'ongoing';
        case 1:
          return m.status == 'scheduled';
        case 2:
          return m.status == 'completed';
        default:
          return true;
      }
    }).toList();
  }

  void changeFilter(int index) {
    selectedFilter.value = index;
  }

  Future<void> createMeeting() async {
    if (!_validateForm()) return;

    try {
      isLoadingActionObs.value = true;
      fieldErrors.clear();

      // TODO: implement call to CreateMeetingUseCase()

      _notif.showSuccess("Rapat berhasil dibuat");
      clearForm();
      fetchMeetings();
      Get.back();
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in createMeeting: ${e.message}',
      );
      _errorMessage.value = e.message;
      _setFieldErrors(e);
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[MeetingController] Exception in createMeeting: $e');
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // -------------------------------
  // 🔵 UPDATE MEETING (placeholder)
  // -------------------------------
  Future<void> updateMeeting() async {
    if (selectedMeeting.value == null) return;
    if (!_validateForm()) return;

    try {
      isLoadingActionObs.value = true;
      fieldErrors.clear();

      // TODO: implement UpdateMeetingUseCase()

      _notif.showSuccess("Rapat berhasil diperbarui");
      clearForm();
      fetchMeetings();
      Get.back();
    } on ApiException catch (e) {
      debugPrint(
        '[MeetingController] ApiException in updateMeeting: ${e.message}',
      );
      _errorMessage.value = e.message;
      _setFieldErrors(e);
      _notif.showError(e.message);
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // -------------------------------
  // 🔴 DELETE MEETING (placeholder)
  // -------------------------------
  Future<void> deleteMeeting(int id) async {
    final meeting = meetings.firstWhereOrNull((e) => e.id == id);
    final name = meeting?.title ?? "rapat ini";

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Konfirmasi"),
        content: Text('Hapus "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoadingActionObs.value = true;

      // TODO: implement DeleteMeetingUseCase()

      _notif.showSuccess('Rapat "$name" berhasil dihapus');
      fetchMeetings();
    } on ApiException catch (e) {
      _notif.showError(e.message);
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // -------------------------------
  // Helpers
  // -------------------------------
  void prepareEdit(Meeting meeting) {
    selectedMeeting.value = meeting;
    fetchMeetingById(meeting);
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    locationController.clear();
    agendaController.clear();
    dateController.clear();
    startTimeController.clear();
    endTimeController.clear();
    selectedMeeting.value = null;
    fieldErrors.clear();
    _errorMessage.value = "";
  }

  bool _validateForm() {
    fieldErrors.clear();

    if (titleController.text.trim().isEmpty) {
      fieldErrors['title'] = 'Judul rapat wajib diisi';
      _notif.showWarning('Judul rapat wajib diisi');
      return false;
    }

    return true;
  }

  void _setFieldErrors(ApiException e) {
    if (e.errors != null) {
      e.errors!.forEach((key, value) {
        if (value.isNotEmpty) fieldErrors[key] = value.first;
      });
    }
  }

  String? getFieldError(String field) => fieldErrors[field];

  void clearFieldError(String field) {
    fieldErrors.remove(field);
  }
}
