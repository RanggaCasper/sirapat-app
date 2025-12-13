import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;
  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    if (mounted) {
      currentPasswordController.dispose();
      newPasswordController.dispose();
      confirmPasswordController.dispose();
      obscureCurrentPassword.close();
      obscureNewPassword.close();
      obscureConfirmPassword.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        centerTitle: false,
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pastikan password baru Anda kuat dan mudah diingat',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Form Fields
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Password
                    Text(
                      'Password Saat Ini',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: currentPasswordController,
                            obscureText: obscureCurrentPassword.value,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password saat ini',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureCurrentPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  obscureCurrentPassword.value =
                                      !obscureCurrentPassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError(
                                            'current_password',
                                          ) !=
                                          null
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              errorText: controller.getFieldError(
                                'current_password',
                              ),
                            ),
                            onChanged: (value) {
                              if (controller.getFieldError(
                                    'current_password',
                                  ) !=
                                  null) {
                                controller.clearFieldError('current_password');
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // New Password
                    Text(
                      'Password Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: newPasswordController,
                            obscureText: obscureNewPassword.value,
                            decoration: InputDecoration(
                              hintText: 'Masukkan password baru',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureNewPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  obscureNewPassword.value =
                                      !obscureNewPassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('password') !=
                                          null
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              errorText: controller.getFieldError('password'),
                            ),
                            onChanged: (value) {
                              if (controller.getFieldError('password') !=
                                  null) {
                                controller.clearFieldError('password');
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password
                    Text(
                      'Konfirmasi Password Baru',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirmPassword.value,
                            decoration: InputDecoration(
                              hintText: 'Konfirmasi password baru',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscureConfirmPassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  obscureConfirmPassword.value =
                                      !obscureConfirmPassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError(
                                            'password_confirmation',
                                          ) !=
                                          null
                                      ? Colors.red
                                      : Colors.grey.shade300,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              errorText: controller.getFieldError(
                                'password_confirmation',
                              ),
                            ),
                            onChanged: (value) {
                              if (controller.getFieldError(
                                    'password_confirmation',
                                  ) !=
                                  null) {
                                controller.clearFieldError(
                                  'password_confirmation',
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24), const SizedBox(height: 24),

              // Password Requirements
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Persyaratan Password:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirement('Minimal 8 karakter'),
                    _buildRequirement('Mengandung huruf besar dan kecil'),
                    _buildRequirement('Mengandung angka'),
                    _buildRequirement('Mengandung karakter khusus (!@#\$%^&*)'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isLoading
                        ? null
                        : () async {
                            if (!mounted) return;

                            // Get text values before async operation
                            final oldPassword = currentPasswordController.text;
                            final newPassword = newPasswordController.text;
                            final newPasswordConfirmation =
                                confirmPasswordController.text;

                            await controller.resetPassword(
                              oldPassword: oldPassword,
                              newPassword: newPassword,
                              newPasswordConfirmation: newPasswordConfirmation,
                            );

                            // Check if widget is still mounted after async operation
                            if (!mounted) return;
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Simpan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
