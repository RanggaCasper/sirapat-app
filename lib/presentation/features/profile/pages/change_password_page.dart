import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  final RxBool obscureCurrentPassword = true.obs;
  final RxBool obscureNewPassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final controller = Get.find<AuthController>();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      await controller.resetPassword(
        oldPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
        newPasswordConfirmation: confirmPasswordController.text,
      );

      if (!mounted) return;

      if (controller.fieldErrors.isEmpty) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('[ChangePasswordPage] Error: $e');
    }
  }

  void _handleCancel() {
    Navigator.of(context).pop();
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Pastikan password baru Anda kuat dan aman.',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // CURRENT PASSWORD
                    Obx(
                      () => CustomTextField(
                        controller: currentPasswordController,
                        labelText: 'Password Saat Ini',
                        hintText: 'Masukkan password saat ini',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscureCurrentPassword.value,
                        errorText: controller.getFieldError('current_password'),
                        onChanged: (_) =>
                            controller.clearFieldError('current_password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureCurrentPassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: obscureCurrentPassword.toggle,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password saat ini tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // NEW PASSWORD
                    Obx(
                      () => CustomTextField(
                        controller: newPasswordController,
                        labelText: 'Password Baru',
                        hintText: 'Masukkan password baru',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscureNewPassword.value,
                        errorText: controller.getFieldError('password'),
                        onChanged: (_) =>
                            controller.clearFieldError('password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureNewPassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: obscureNewPassword.toggle,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru tidak boleh kosong';
                          }
                          if (value.length < 8) {
                            return 'Password minimal 8 karakter';
                          }
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Harus mengandung huruf besar';
                          }
                          if (!RegExp(r'[a-z]').hasMatch(value)) {
                            return 'Harus mengandung huruf kecil';
                          }
                          if (!RegExp(r'\d').hasMatch(value)) {
                            return 'Harus mengandung angka';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]')
                              .hasMatch(value)) {
                            return 'Harus mengandung simbol';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CONFIRM PASSWORD
                    Obx(
                      () => CustomTextField(
                        controller: confirmPasswordController,
                        labelText: 'Konfirmasi Password Baru',
                        hintText: 'Ulangi password baru',
                        prefixIcon: Icons.lock_outline,
                        obscureText: obscureConfirmPassword.value,
                        errorText:
                            controller.getFieldError('password_confirmation'),
                        onChanged: (_) =>
                            controller.clearFieldError('password_confirmation'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmPassword.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                          onPressed: obscureConfirmPassword.toggle,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != newPasswordController.text) {
                            return 'Konfirmasi password tidak cocok';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // PASSWORD REQUIREMENTS
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Persyaratan Password:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement('Minimal 8 karakter'),
                          _buildRequirement('Mengandung huruf besar dan kecil'),
                          _buildRequirement('Mengandung angka'),
                          _buildRequirement('Mengandung karakter khusus'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
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
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: _handleCancel,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                        ),
                        child: const Text(
                          'Batal',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: controller.isLoading ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppRadius.radiusMD,
                            ),
                            elevation: 0,
                          ),
                          child: controller.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Simpan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
