import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      fieldErrors.clear();

      // Fetch all data from API
      final result = await _getDivisionsUseCase.execute();
      _allDivisions.value = result;

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
    if (!_validateForm()) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

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
      debugPrint(
        '[DivisionController] ApiException in createDivision: ${e.message}',
      );
      debugPrint('[DivisionController] Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal menambah divisi: ${e.message}');

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
          }
        });
      } else {
        fieldErrors['name'] = e.message;
      }
    } catch (e) {
      debugPrint('[DivisionController] Exception in createDivision: $e');
      _errorMessage.value = e.toString();
      fieldErrors['name'] = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Update existing division
  Future<void> updateDivision() async {
    if (selectedDivision.value == null) return;
    if (!_validateForm()) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

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
      debugPrint(
        '[DivisionController] ApiException in updateDivision: ${e.message}',
      );
      debugPrint('[DivisionController] Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal memperbarui divisi: ${e.message}');

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
          }
        });
      } else {
        fieldErrors['name'] = e.message;
      }
    } catch (e) {
      debugPrint('[DivisionController] Exception in updateDivision: $e');
      _errorMessage.value = e.toString();
      fieldErrors['name'] = e.toString();
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

    // Show confirmation dialog
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$divisionName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(Get.context!).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (confirmed != true) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      await _deleteDivisionUseCase.execute(id);

      _notif.showSuccess('Divisi "$divisionName" berhasil dihapus');

      fetchDivisions();
    } on ApiException catch (e) {
      debugPrint(
        '[DivisionController] ApiException in deleteDivision: ${e.message}',
      );

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
    fieldErrors.clear();
    _errorMessage.value = '';
  }

  // Validate form
  bool _validateForm() {
    fieldErrors.clear();

    if (nameController.text.trim().isEmpty) {
      fieldErrors['name'] = 'Nama divisi wajib diisi';
      _notif.showWarning('Nama divisi wajib diisi');
      return false;
    }

    return true;
  }

  // Get field error
  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    fieldErrors.remove(fieldName);
  }
}
