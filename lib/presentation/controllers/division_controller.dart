import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/division.dart';
import 'package:sirapat_app/domain/usecases/division/get_divisions_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/get_division_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/create_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/update_division_usecase.dart';
import 'package:sirapat_app/domain/usecases/division/delete_division_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

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
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

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
    super.onClose();
  }

  // Fetch all divisions
  Future<void> fetchDivisions() async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      final divisionList = await _getDivisionsUseCase.execute();
      divisions.value = divisionList;

      print('Divisions fetched successfully: ${divisionList.length} items');
    } on ApiException catch (e) {
      print('Controller - ApiException caught: ${e.message}');
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingObs.value = false;
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

      print('Division fetched by ID: ${division.name}');
    } on ApiException catch (e) {
      print('Controller - ApiException caught: ${e.message}');
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      print('Controller - Generic exception: $e');
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

      print('Division created successfully: ${division.name}');

      // Show success toast
      _notif.showSuccess('Divisi "${division.name}" berhasil ditambahkan');

      clearForm();
      fetchDivisions();
      Get.back(); // Close dialog/form
    } on ApiException catch (e) {
      print('Controller - Create ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal menambah divisi: ${e.message}');

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      } else {
        fieldErrors['name'] = e.message;
      }
    } catch (e) {
      print('Controller - Generic exception: $e');
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

      print('Division updated successfully: ${division.name}');
      _notif.showSuccess('Divisi "${division.name}" berhasil diperbarui');

      clearForm();
      fetchDivisions();
      Get.back(); // Close dialog/form
    } on ApiException catch (e) {
      print('Controller - Update ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal memperbarui divisi: ${e.message}');

      // Set field-specific errors
      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      } else {
        fieldErrors['name'] = e.message;
      }
    } catch (e) {
      print('Controller - Generic exception: $e');
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
            onPressed: () => Get.back(result: false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      await _deleteDivisionUseCase.execute(id);

      print('Division deleted successfully: ID $id');
      _notif.showSuccess('Divisi "$divisionName" berhasil dihapus');

      fetchDivisions();
    } on ApiException catch (e) {
      print('Controller - Delete ApiException caught');
      print('Message: ${e.message}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal menghapus divisi: ${e.message}');
    } catch (e) {
      print('Controller - Generic exception: $e');
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
