import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/entities/pagination.dart';
import 'package:sirapat_app/domain/usecases/user/get_users_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/get_user_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/create_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_role_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/delete_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/change_password_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class UserController extends GetxController {
  final GetUsersUseCase _getUsersUseCase;
  final GetUserByIdUseCase _getUserByIdUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;

  UserController(
    this._getUsersUseCase,
    this._getUserByIdUseCase,
    this._createUserUseCase,
    this._updateUserUseCase,
    this._updateUserRoleUseCase,
    this._deleteUserUseCase,
    this._changePasswordUseCase,
  );

  // Observable lists
  final RxList<User> users = <User>[].obs;
  final RxList<User> _allUsers = <User>[].obs;
  final Rx<PaginationMeta?> paginationMeta = Rx<PaginationMeta?>(null);
  final RxBool isLoadingObs = false.obs;
  final RxBool isLoadingActionObs = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;

  // Form controllers
  final TextEditingController nipController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final TextEditingController profilePhotoController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  // Password change controllers
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newPasswordConfirmationController =
      TextEditingController();

  // Selected user for edit
  final Rx<User?> selectedUser = Rx<User?>(null);
  final RxString selectedRole = 'employee'.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscurePasswordConfirmation = true.obs;

  bool get isLoading => isLoadingObs.value;
  bool get isLoadingAction => isLoadingActionObs.value;
  String get errorMessage => _errorMessage.value;
  bool get isEditMode => selectedUser.value != null;

  // Notification helper
  NotificationController get _notif => Get.find<NotificationController>();

  // Role options
  final List<Map<String, String>> roleOptions = [
    {'value': 'employee', 'label': 'Karyawan'},
    {'value': 'admin', 'label': 'Admin'},
    {'value': 'master', 'label': 'Master'},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
  }

  @override
  void onClose() {
    nipController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    fullNameController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    profilePhotoController.dispose();
    searchController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordConfirmationController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void togglePasswordConfirmationVisibility() {
    obscurePasswordConfirmation.value = !obscurePasswordConfirmation.value;
  }

  // Fetch all users from API (only once)
  Future<void> fetchUsers({int page = 1, int perPage = 10}) async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      // Fetch all data from API
      final result = await _getUsersUseCase.execute();
      _allUsers.value = result;

      // After fetching, apply pagination on client side
      _applyPagination(page: page, perPage: perPage);
    } on ApiException catch (e) {
      debugPrint('[UserController] ApiException in fetchUsers: ${e.message}');
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[UserController] Exception in fetchUsers: $e');
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
        ? _allUsers
        : _allUsers.where((user) {
            final query = searchQuery.value.toLowerCase();
            final fullName = (user.fullName ?? '').toLowerCase();
            final nip = (user.nip ?? '').toLowerCase();
            final email = (user.email ?? '').toLowerCase();
            final username = (user.username ?? '').toLowerCase();
            return fullName.contains(query) ||
                nip.contains(query) ||
                email.contains(query) ||
                username.contains(query);
          }).toList();

    // Calculate pagination
    final totalItems = filteredData.length;
    final lastPage = totalItems > 0 ? (totalItems / perPage).ceil() : 1;
    final startIndex = (page - 1) * perPage;
    final endIndex = (startIndex + perPage).clamp(0, totalItems);

    // Get items for current page
    users.value = totalItems > 0
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

  // Search users (client-side filter)
  void searchUsers(String query) {
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

  // Get user by ID
  Future<void> fetchUserById(int id) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      final user = await _getUserByIdUseCase.execute(id);
      selectedUser.value = user;
      _populateForm(user);
    } on ApiException catch (e) {
      debugPrint(
        '[UserController] ApiException in fetchUserById: ${e.message}',
      );
      _errorMessage.value = e.message;
      _notif.showError(e.message);
    } catch (e) {
      debugPrint('[UserController] Exception in fetchUserById: $e');
      _errorMessage.value = e.toString();
      _notif.showError(e.toString());
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Create new user
  Future<void> createUser() async {
    if (!_validateForm(isEdit: false)) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      final user = await _createUserUseCase.execute(
        CreateUserParams(
          nip: nipController.text.trim(),
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          fullName: fullNameController.text.trim(),
          password: passwordController.text.trim(),
          passwordConfirmation: passwordConfirmationController.text.trim(),
          profilePhoto: profilePhotoController.text.trim().isEmpty
              ? null
              : profilePhotoController.text.trim(),
          role: selectedRole.value,
        ),
      );

      // Show success toast
      _notif.showSuccess('Pengguna "${user.fullName}" berhasil ditambahkan');

      clearForm();

      // Navigate back and refresh
      Get.back();
      await fetchUsers();
    } on ApiException catch (e) {
      debugPrint('[UserController] ApiException in createUser: ${e.message}');
      debugPrint('[UserController] Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError(e.message);

      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
          }
        });
      } else {
        fieldErrors['nip'] = e.message;
      }
    } catch (e) {
      debugPrint('[UserController] Exception in createUser: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal menambah pengguna: ${e.toString().replaceAll('Exception: ', '')}';
      fieldErrors['nip'] = errorMsg;

      _notif.showError(errorMsg);
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Update existing user
  Future<void> updateUser() async {
    if (selectedUser.value == null) return;
    if (!_validateForm(isEdit: true)) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      final user = await _updateUserUseCase.execute(
        UpdateUserParams(
          id: selectedUser.value!.id!,
          nip: nipController.text.trim(),
          username: usernameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          fullName: fullNameController.text.trim(),
          profilePhoto: profilePhotoController.text.trim().isEmpty
              ? null
              : profilePhotoController.text.trim(),
          role: selectedRole.value,
        ),
      );

      _notif.showSuccess('Pengguna "${user.fullName}" berhasil diperbarui');

      clearForm();

      // Navigate back and refresh
      Get.back();
      await fetchUsers();
    } on ApiException catch (e) {
      debugPrint('[UserController] ApiException in updateUser: ${e.message}');
      debugPrint('[UserController] Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal memperbarui pengguna: ${e.message}');

      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
          }
        });
      } else {
        fieldErrors['nip'] = e.message;
      }
    } catch (e) {
      debugPrint('[UserController] Exception in updateUser: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal memperbarui pengguna: ${e.toString().replaceAll('Exception: ', '')}';
      fieldErrors['nip'] = errorMsg;

      _notif.showError(errorMsg);
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Update user role only
  Future<void> updateUserRole(int userId, String newRole) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      final user = await _updateUserRoleUseCase.execute(
        UpdateUserRoleParams(id: userId, role: newRole),
      );

      _notif.showSuccess(
        'Role pengguna "${user.fullName}" berhasil diperbarui',
      );

      fetchUsers();
      Get.back();
    } on ApiException catch (e) {
      debugPrint(
        '[UserController] ApiException in updateUserRole: ${e.message}',
      );

      _errorMessage.value = e.message;

      _notif.showError('Gagal mengubah role pengguna: ${e.message}');
    } catch (e) {
      debugPrint('[UserController] Exception in updateUserRole: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal mengubah role user: ${e.toString()}');
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    final user = users.firstWhereOrNull((u) => u.id == id);
    final userName = user?.fullName ?? 'pengguna ini';

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
              'Apakah Anda yakin ingin menghapus "$userName"?',
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

      await _deleteUserUseCase.execute(id);

      _notif.showSuccess('Pengguna "$userName" berhasil dihapus');

      fetchUsers();
    } on ApiException catch (e) {
      debugPrint('[UserController] ApiException in deleteUser: ${e.message}');

      _errorMessage.value = e.message;

      _notif.showError('Gagal menghapus pengguna: ${e.message}');
    } catch (e) {
      debugPrint('[UserController] Exception in deleteUser: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal menghapus pengguna: ${e.toString()}');
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Change password
  Future<void> changePassword(int userId) async {
    if (!_validatePasswordForm()) return;

    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      await _changePasswordUseCase.execute(
        ChangePasswordParams(
          id: userId,
          currentPassword: currentPasswordController.text.trim(),
          newPassword: newPasswordController.text.trim(),
          newPasswordConfirmation: newPasswordConfirmationController.text
              .trim(),
        ),
      );

      _notif.showSuccess('Password berhasil diubah');

      _clearPasswordForm();
      Get.back();
    } on ApiException catch (e) {
      debugPrint(
        '[UserController] ApiException in changePassword: ${e.message}',
      );
      debugPrint('[UserController] Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal mengubah password: ${e.message}');

      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
          }
        });
      }
    } catch (e) {
      debugPrint('[UserController] Exception in changePassword: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal mengubah password: ${e.toString()}');
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Prepare for edit
  void prepareEdit(User user) {
    selectedUser.value = user;
    _populateForm(user);
  }

  void _populateForm(User user) {
    nipController.text = user.nip!;
    usernameController.text = user.username!;
    emailController.text = user.email!;
    phoneController.text = user.phone!;
    fullNameController.text = user.fullName!;
    profilePhotoController.text = user.profilePhoto ?? '';
    selectedRole.value = user.role!;
  }

  // Clear form
  void clearForm() {
    nipController.clear();
    usernameController.clear();
    emailController.clear();
    phoneController.clear();
    fullNameController.clear();
    passwordController.clear();
    passwordConfirmationController.clear();
    profilePhotoController.clear();
    selectedUser.value = null;
    selectedRole.value = 'employee';
    fieldErrors.clear();
    _errorMessage.value = '';
    obscurePassword.value = true;
    obscurePasswordConfirmation.value = true;
  }

  void _clearPasswordForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    newPasswordConfirmationController.clear();
    fieldErrors.clear();
  }

  // Validate form
  bool _validateForm({required bool isEdit}) {
    fieldErrors.clear();

    if (nipController.text.trim().isEmpty) {
      fieldErrors['nip'] = 'NIP wajib diisi';
      _showValidationError('NIP wajib diisi');
      return false;
    }

    if (usernameController.text.trim().isEmpty) {
      fieldErrors['username'] = 'Username wajib diisi';
      _showValidationError('Username wajib diisi');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      fieldErrors['email'] = 'Email wajib diisi';
      _showValidationError('Email wajib diisi');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      fieldErrors['email'] = 'Format email tidak valid';
      _showValidationError('Format email tidak valid');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      fieldErrors['phone'] = 'Nomor telepon wajib diisi';
      _showValidationError('Nomor telepon wajib diisi');
      return false;
    }

    if (fullNameController.text.trim().isEmpty) {
      fieldErrors['full_name'] = 'Nama lengkap wajib diisi';
      _showValidationError('Nama lengkap wajib diisi');
      return false;
    }

    // Password validation only for create
    if (!isEdit) {
      if (passwordController.text.trim().isEmpty) {
        fieldErrors['password'] = 'Password wajib diisi';
        _showValidationError('Password wajib diisi');
        return false;
      }

      if (passwordController.text.trim().length < 8) {
        fieldErrors['password'] = 'Password minimal 8 karakter';
        _showValidationError('Password minimal 8 karakter');
        return false;
      }

      if (passwordController.text != passwordConfirmationController.text) {
        fieldErrors['password_confirmation'] =
            'Konfirmasi password tidak cocok';
        _showValidationError('Konfirmasi password tidak cocok');
        return false;
      }
    }

    return true;
  }

  bool _validatePasswordForm() {
    fieldErrors.clear();

    if (currentPasswordController.text.trim().isEmpty) {
      fieldErrors['current_password'] = 'Password saat ini wajib diisi';
      _showValidationError('Password saat ini wajib diisi');
      return false;
    }

    if (newPasswordController.text.trim().isEmpty) {
      fieldErrors['new_password'] = 'Password baru wajib diisi';
      _showValidationError('Password baru wajib diisi');
      return false;
    }

    if (newPasswordController.text.trim().length < 8) {
      fieldErrors['new_password'] = 'Password baru minimal 8 karakter';
      _showValidationError('Password baru minimal 8 karakter');
      return false;
    }

    if (newPasswordController.text != newPasswordConfirmationController.text) {
      fieldErrors['new_password_confirmation'] =
          'Konfirmasi password tidak cocok';
      _showValidationError('Konfirmasi password tidak cocok');
      return false;
    }

    return true;
  }

  void _showValidationError(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        'Validasi Error',
        message,
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
      );
    });
  }

  // Get field error
  String? getFieldError(String fieldName) {
    return fieldErrors[fieldName];
  }

  // Clear field error
  void clearFieldError(String fieldName) {
    fieldErrors.remove(fieldName);
  }

  // Get role label
  String getRoleLabel(String role) {
    return roleOptions.firstWhere(
      (r) => r['value'] == role,
      orElse: () => {'value': role, 'label': role},
    )['label']!;
  }
}
