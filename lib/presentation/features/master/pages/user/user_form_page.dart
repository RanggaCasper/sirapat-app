import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/user_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

/// Halaman form untuk create/edit user
class UserFormPage extends StatelessWidget {
  final bool isEdit;

  const UserFormPage({Key? key, this.isEdit = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Pengguna' : 'Tambah Pengguna'),
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.paddingLG,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // NIP Field
                  Obx(
                    () => CustomTextField(
                      controller: controller.nipController,
                      labelText: 'NIP *',
                      hintText: 'Masukkan NIP',
                      prefixIcon: Icons.badge_outlined,
                      errorText: controller.getFieldError('nip'),
                      onChanged: (value) {
                        if (controller.getFieldError('nip') != null) {
                          controller.clearFieldError('nip');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name Field
                  Obx(
                    () => CustomTextField(
                      controller: controller.fullNameController,
                      labelText: 'Nama Lengkap *',
                      hintText: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person_outlined,
                      errorText: controller.getFieldError('full_name'),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        if (controller.getFieldError('full_name') != null) {
                          controller.clearFieldError('full_name');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  Obx(
                    () => CustomTextField(
                      controller: controller.usernameController,
                      labelText: 'Username *',
                      hintText: 'Masukkan username',
                      prefixIcon: Icons.account_circle_outlined,
                      errorText: controller.getFieldError('username'),
                      onChanged: (value) {
                        if (controller.getFieldError('username') != null) {
                          controller.clearFieldError('username');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  Obx(
                    () => CustomTextField(
                      controller: controller.emailController,
                      labelText: 'Email *',
                      hintText: 'Masukkan email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: controller.getFieldError('email'),
                      onChanged: (value) {
                        if (controller.getFieldError('email') != null) {
                          controller.clearFieldError('email');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  Obx(
                    () => CustomTextField(
                      controller: controller.phoneController,
                      labelText: 'Nomor Telepon *',
                      hintText: 'Masukkan nomor telepon',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: controller.getFieldError('phone'),
                      onChanged: (value) {
                        if (controller.getFieldError('phone') != null) {
                          controller.clearFieldError('phone');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Role Dropdown
                  Obx(() {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Role *',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderLight),
                            borderRadius: AppRadius.radiusMD,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedRole.value,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.admin_panel_settings_outlined,
                              ),
                            ),
                            items: controller.roleOptions
                                .map(
                                  (role) => DropdownMenuItem(
                                    value: role['value'],
                                    child: Text(role['label']!),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                controller.selectedRole.value = value;
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }),

                  // Password fields for create mode
                  if (!isEdit) ...[
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordController,
                        labelText: 'Password *',
                        hintText: 'Masukkan password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText: controller.obscurePassword.value,
                        errorText: controller.getFieldError('password'),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePassword.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: controller.togglePasswordVisibility,
                        ),
                        onChanged: (value) {
                          if (controller.getFieldError('password') != null) {
                            controller.clearFieldError('password');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => CustomTextField(
                        controller: controller.passwordConfirmationController,
                        labelText: 'Konfirmasi Password *',
                        hintText: 'Ulangi password',
                        prefixIcon: Icons.lock_outlined,
                        obscureText:
                            controller.obscurePasswordConfirmation.value,
                        errorText: controller.getFieldError(
                          'password_confirmation',
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.obscurePasswordConfirmation.value
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed:
                              controller.togglePasswordConfirmationVisibility,
                        ),
                        onChanged: (value) {
                          if (controller.getFieldError(
                                'password_confirmation',
                              ) !=
                              null) {
                            controller.clearFieldError('password_confirmation');
                          }
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  Text(
                    '* Wajib diisi',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Actions
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
                    child: OutlinedButton(
                      onPressed: () {
                        if (Get.isDialogOpen ?? false) {
                          Get.back();
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoadingActionObs.value
                            ? null
                            : () {
                                if (isEdit) {
                                  controller.updateUser();
                                } else {
                                  controller.createUser();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isEdit ? Colors.blue : Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoadingActionObs.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                isEdit ? 'Simpan' : 'Tambah',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
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
