import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/domain/entities/user.dart';
import 'package:sirapat_app/domain/usecases/user/get_users_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/get_user_by_id_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/create_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/update_user_role_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/delete_user_usecase.dart';
import 'package:sirapat_app/domain/usecases/user/change_password_usecase.dart';
import 'package:sirapat_app/data/models/api_exception.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

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

  // Fetch all users
  Future<void> fetchUsers() async {
    try {
      isLoadingObs.value = true;
      _errorMessage.value = '';
      fieldErrors.clear();

      final userList = await _getUsersUseCase.execute();
      users.value = userList ?? [];

      print('Users fetched successfully: ${users.length} items');
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

  // Get user by ID
  Future<void> fetchUserById(int id) async {
    try {
      isLoadingActionObs.value = true;
      _errorMessage.value = '';

      final user = await _getUserByIdUseCase.execute(id);
      selectedUser.value = user;
      _populateForm(user);

      print('User fetched by ID: ${user.fullName}');
    } on ApiException catch (e) {
      print('Controller - ApiException caught: ${e.message}');
      _errorMessage.value = e.message;

      _notif.showError(e.message);
    } catch (e) {
      print('Controller - Generic exception: $e');
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

      print('User created successfully: ${user.fullName}');

      clearForm();
      fetchUsers();
      Get.back();
    } on ApiException catch (e) {
      print('Controller - Create ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError(e.message);

      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      } else {
        fieldErrors['nip'] = e.message;
      }
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal menambah user: ${e.toString().replaceAll('Exception: ', '')}';
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

      print('User updated successfully: ${user.fullName}');
      _notif.showSuccess('User "${user.fullName}" berhasil diperbarui');

      clearForm();
      fetchUsers();
      Get.back();
    } on ApiException catch (e) {
      print('Controller - Update ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

      _errorMessage.value = e.message;
      _notif.showError('Gagal memperbarui user: ${e.message}');

      if (e.errors != null && e.errors!.isNotEmpty) {
        e.errors!.forEach((field, messages) {
          if (messages.isNotEmpty) {
            fieldErrors[field] = messages.first;
            print('Setting error for field $field: ${messages.first}');
          }
        });
      } else {
        fieldErrors['nip'] = e.message;
      }
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();

      String errorMsg =
          'Gagal memperbarui user: ${e.toString().replaceAll('Exception: ', '')}';
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

      print('User role updated successfully: ${user.fullName} -> $newRole');

      _notif.showSuccess('Role user "${user.fullName}" berhasil diperbarui');

      fetchUsers();
      Get.back();
    } on ApiException catch (e) {
      print('Controller - Update Role ApiException caught');
      print('Message: ${e.message}');

      _errorMessage.value = e.message;

      _notif.showError('Gagal mengubah role user: ${e.message}');
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal mengubah role user: ${e.toString()}');
    } finally {
      isLoadingActionObs.value = false;
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    final user = users.firstWhereOrNull((u) => u.id == id);
    final userName = user?.fullName ?? 'user ini';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "$userName"?'),
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

      await _deleteUserUseCase.execute(id);

      print('User deleted successfully: ID $id');

      _notif.showSuccess('User "$userName" berhasil dihapus');

      fetchUsers();
    } on ApiException catch (e) {
      print('Controller - Delete ApiException caught');
      print('Message: ${e.message}');

      _errorMessage.value = e.message;

      _notif.showError('Gagal menghapus user: ${e.message}');
    } catch (e) {
      print('Controller - Generic exception: $e');
      _errorMessage.value = e.toString();

      _notif.showError('Gagal menghapus user: ${e.toString()}');
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

      print('Password changed successfully for user ID: $userId');

      _notif.showSuccess('Password berhasil diubah');

      _clearPasswordForm();
      Get.back();
    } on ApiException catch (e) {
      print('Controller - Change Password ApiException caught');
      print('Message: ${e.message}');
      print('Errors: ${e.errors}');

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
      print('Controller - Generic exception: $e');
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
