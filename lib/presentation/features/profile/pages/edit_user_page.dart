import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/app/config/app_dimensions.dart';
import 'package:sirapat_app/app/config/app_text_styles.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/controllers/division_controller.dart';
import 'package:sirapat_app/presentation/controllers/division_binding.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  // Text controllers untuk menghindari recreation
  late final TextEditingController nipController;
  late final TextEditingController fullNameController;
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;

  // Selected division ID (as String for dropdown)
  String? selectedDivisionId;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();

    nipController = TextEditingController(
      text: authController.currentUser?.nip,
    );
    fullNameController = TextEditingController(
      text: authController.currentUser?.fullName,
    );
    usernameController = TextEditingController(
      text: authController.currentUser?.username,
    );
    emailController = TextEditingController(
      text: authController.currentUser?.email,
    );
    phoneController = TextEditingController(
      text: authController.currentUser?.phone,
    );

    // Set initial division value
    if (authController.currentUser?.divisionId != null) {
      selectedDivisionId = authController.currentUser!.divisionId.toString();
    }
  }

  @override
  void dispose() {
    nipController.dispose();
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    // Ensure DivisionController is registered (in case navigation didn't apply bindings)
    if (!Get.isRegistered<DivisionController>()) {
      DivisionBinding().dependencies();
    }
    final divisionController = Get.find<DivisionController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      controller: nipController,
                      labelText: 'NIP *',
                      hintText: 'Masukkan NIP',
                      prefixIcon: Icons.badge_outlined,
                      errorText: authController.getFieldError('nip'),
                      readOnly: true,
                      onChanged: (value) {
                        if (authController.getFieldError('nip') != null) {
                          authController.clearFieldError('nip');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Full Name Field
                  Obx(
                    () => CustomTextField(
                      controller: fullNameController,
                      labelText: 'Nama Lengkap *',
                      hintText: 'Masukkan nama lengkap',
                      prefixIcon: Icons.person_outlined,
                      errorText: authController.getFieldError('full_name'),
                      textCapitalization: TextCapitalization.words,
                      onChanged: (value) {
                        if (authController.getFieldError('full_name') != null) {
                          authController.clearFieldError('full_name');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Username Field
                  Obx(
                    () => CustomTextField(
                      controller: usernameController,
                      labelText: 'Username *',
                      hintText: 'Masukkan username',
                      prefixIcon: Icons.account_circle_outlined,
                      errorText: authController.getFieldError('username'),
                      readOnly: true,
                      onChanged: (value) {
                        if (authController.getFieldError('username') != null) {
                          authController.clearFieldError('username');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  Obx(
                    () => CustomTextField(
                      controller: emailController,
                      labelText: 'Email *',
                      hintText: 'Masukkan email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      errorText: authController.getFieldError('email'),
                      readOnly: true,
                      onChanged: (value) {
                        if (authController.getFieldError('email') != null) {
                          authController.clearFieldError('email');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  Obx(
                    () => CustomTextField(
                      controller: phoneController,
                      labelText: 'Nomor Telepon *',
                      hintText: 'Masukkan nomor telepon',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      errorText: authController.getFieldError('phone'),
                      onChanged: (value) {
                        if (authController.getFieldError('phone') != null) {
                          authController.clearFieldError('phone');
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divisi Dropdown
                  Obx(() {
                    final divisions = divisionController.divisionOptions;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Divisi *',
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
                            value: selectedDivisionId,
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
                            hint: const Text('Pilih Divisi'),
                            isExpanded: true,
                            items: divisions.isEmpty
                                ? []
                                : divisions.map((division) {
                                    return DropdownMenuItem<String>(
                                      value: division.id.toString(),
                                      child: Text(
                                        division.name,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                            onChanged: divisions.isEmpty
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedDivisionId = value;
                                    });
                                  },
                          ),
                        ),
                        if (divisions.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Tidak ada divisi tersedia',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                      ],
                    );
                  }),

                  const SizedBox(height: 12),
                  const Text(
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
                          Navigator.of(context).pop();
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
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: authController.isLoading
                            ? null
                            : () async {
                                // Validate division selected
                                if (selectedDivisionId == null ||
                                    selectedDivisionId!.isEmpty) {
                                  final notif =
                                      Get.find<NotificationController>();
                                  notif.showError('Silakan pilih divisi');
                                  return;
                                }

                                // Save role before update (role shouldn't change)
                                final userRole = authController
                                    .currentUser
                                    ?.role
                                    ?.toLowerCase();

                                await authController.updateProfile(
                                  fullName: fullNameController.text.trim(),
                                  phone: phoneController.text.trim(),
                                  divisionId: int.parse(selectedDivisionId!),
                                );

                                if (authController.fieldErrors.isEmpty &&
                                    context.mounted) {
                                  // Navigate back to appropriate dashboard based on original role
                                  if (userRole != null) {
                                    String targetRoute;
                                    switch (userRole) {
                                      case 'master':
                                        targetRoute = '/master-dashboard';
                                        break;
                                      case 'admin':
                                        targetRoute = '/admin-dashboard';
                                        break;
                                      case 'employee':
                                        targetRoute = '/employee-dashboard';
                                        break;
                                      default:
                                        // Default fallback
                                        Navigator.of(context).pop();
                                        return;
                                    }
                                    // Navigate to dashboard and remove all previous routes
                                    Get.offAllNamed(targetRoute);
                                  } else {
                                    Navigator.of(context).pop();
                                  }
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.radiusMD,
                          ),
                          elevation: 0,
                        ),
                        child: authController.isLoading
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
                            : const Text(
                                'Simpan',
                                style: TextStyle(
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
