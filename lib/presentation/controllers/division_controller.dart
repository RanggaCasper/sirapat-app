import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/util/form_error_handler.dart';
import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/entities/pagination.dart';
import 'package:sirapat_app/domain/usecases/division/get_divisions_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/get_division_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/create_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/update_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/delete_division_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class DivisionController extends GetxController {
  final GetDivisionsUseCase _getDivisionsUseCase;
  final GetDivisionByIdUseCase _getDivisionByIdUseCase;
  final CreateDivisionUseCase _createDivisionUseCase;
  final UpdateDivisionUseCase _updateDivisionUseCase;
  final DeleteDivisionUsecase _deleteDivisionUseCase;

  DivisionController(
    this._getDivisionsUseCase,
    this._getDivisionByIdUseCase,
    this._createDivisionUseCase,
    this._updateDivisionUseCase,
    this._deleteDivisionUseCase,
  );

  // Observable lists
  final RxList<Division> divisions = <Division>[].obs;
  final RxList<Division> _allDivisions = <Division>[].obs;
  final RxInt totalCount =
      0.obs; // Total count from API (not affected by pagination)
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Selected division for edit
  final Rx<Division?> selectedDivision = Rx<Division?>(null);

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;
  bool get isEditMode => selectedDivision.value != null;

  // Notification helper
  NotificationController get _notif => Get.find<NotificationController>();

  @override
  void onInit() {
    super.onInit();
    fetchDivisions();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.onClose();
  }

  // Fetch all divisions from API (only once)
  Future<void> fetchDivisions({int page = 1, int perPage = 10}) async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      // Fetch all data from API
      final result = await _getDivisionsUseCase.execute();
      _allDivisions.value = result;
      totalCount.value = result.length; // Set real total count

      // After fetching, apply pagination on client side
      _applyPagination(page: page, perPage: perPage);
    } on ApiException catch (e) {
      debugPrint(
        '[DivisionController] ApiException in fetchDivisions: ${e.message}',
      );
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[DivisionController] Exception in fetchDivisions: $e');
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
        ? _allDivisions
        : _allDivisions.where((division) {
            final query = searchQuery.value.toLowerCase();
            final name = division.name.toLowerCase();
            final description = (division.description ?? '').toLowerCase();
            return name.contains(query) || description.contains(query);
          }).toList();

    // Calculate pagination
    final totalItems = filteredData.length;
    final lastPage = totalItems > 0 ? (totalItems / perPage).ceil() : 1;
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, totalItems);

    // Get items for current page
    divisions.value = totalItems > 0
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

  // Search divisions (client-side filter)
  void searchDivisions(String query) {
    searchQuery.value = query;
    _applyPagination(
      page: 1,
      perPage: 10,
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

  // Get division by ID
  Future<void> fetchDivisionById(int id) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      final division = await _getDivisionByIdUseCase.execute(id);
      selectedDivision.value = division;
      nameController.text = division.name;
      descriptionController.text = division.description ?? '';
    } on ApiException catch (e) {
      debugPrint(
        '[DivisionController] ApiException in fetchDivisionById: ${e.message}',
      );
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[DivisionController] Exception in fetchDivisionById: $e');
      _errorMessage.value = e.toString();
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Create new division
  Future<void> createDivision() async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      final division = await _createDivisionUseCase.execute(
        CreateDivisionParams(
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        ),
      );

      // Show success toast
      _notif.showSuccess('Divisi "${division.name}" berhasil ditambahkan');

      clearForm();

      // Navigate back and refresh
      Get.back();
      await fetchDivisions();
    } on ApiException catch (e) {
      final errors = FormErrorHandler.handleApiException(e);
      fieldErrors.addAll(errors);
    } catch (e) {
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Update existing division
  Future<void> updateDivision() async {
    if (selectedDivision.value == null) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      FormErrorHandler.clearAllFieldErrors(fieldErrors);

      final division = await _updateDivisionUseCase.execute(
        UpdateDivisionParams(
          id: selectedDivision.value!.id!,
          name: nameController.text.trim(),
          description: descriptionController.text.trim().isEmpty
              ? null
              : descriptionController.text.trim(),
        ),
      );

      _notif.showSuccess('Divisi "${division.name}" berhasil diperbarui');

      clearForm();

      // Navigate back and refresh
      Get.back();
      await fetchDivisions();
    } on ApiException catch (e) {
      final errors = FormErrorHandler.handleApiException(e);
      fieldErrors.addAll(errors);
    } catch (e) {
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Delete division
  Future<void> deleteDivision(int id) async {
    // Find division name for confirmation
    final division = divisions.firstWhereOrNull((d) => d.id == id);
    final divisionName = division?.name ?? 'divisi ini';

    // Show confirmation bottom sheet
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
            const Text(
              'Konfirmasi Hapus',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              'Apakah Anda yakin ingin menghapus "$divisionName"?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(Get.context!).pop(false),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(Get.context!).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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

      await _deleteDivisionUseCase.execute(id);

      _notif.showSuccess('Divisi "$divisionName" berhasil dihapus');

      fetchDivisions();
    } on ApiException catch (e) {
      _errorMessage.value = e.message;
      _notif.showError('Gagal menghapus divisi: ${e.message}');
    } catch (e) {
      debugPrint('[DivisionController] Exception in deleteDivision: $e');
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Prepare for edit
  void prepareEdit(Division division) {
    selectedDivision.value = division;
    nameController.text = division.name;
    descriptionController.text = division.description ?? '';
  }

  // Clear form
  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    selectedDivision.value = null;
    FormErrorHandler.clearAllFieldErrors(fieldErrors);
    _errorMessage.value = '';
  }

  // Get field error
  String? getFieldError(String fieldName) {
    return FormErrorHandler.getFieldError(fieldErrors, fieldName);
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    FormErrorHandler.clearFieldError(fieldErrors, fieldName);
  }
}
