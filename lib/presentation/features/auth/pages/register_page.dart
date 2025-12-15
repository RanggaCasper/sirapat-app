import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

class RegisterPage extends GetView<AuthController> {
  RegisterPage({super.key});

  final _nipController = TextEditingController();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final RxBool _obscurePassword = true.obs;
  final RxBool _obscurePasswordConfirmation = true.obs;

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      controller.register(
        nip: _nipController.text.trim(),
        username: _usernameController.text.trim(),
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );
    }
  }

  void _handleLogin() {
    Get.toNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double logoSize = (size.width * 0.25).clamp(70.0, 120.0);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/pattern.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.85),
              BlendMode.dstATop,
            ),
            onError: (exception, stackTrace) {},
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      SizedBox(
                        width: logoSize,
                        height: logoSize,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.account_balance,
                            size: logoSize * 0.6,
                            color: AppColors.iconPrimary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'SiRapat',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Sistem Rapat Digital',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // NIP
                      CustomTextField(
                        controller: _nipController,
                        labelText: 'NIP',
                        hintText: 'Nomor Induk Pegawai',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.badge_outlined,
                        errorText: controller.getFieldError('nip'),
                        onTap: () => controller.clearFieldError('nip'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'NIP tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Username
                      CustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        hintText: 'Username',
                        prefixIcon: Icons.person_outline,
                        errorText: controller.getFieldError('username'),
                        onTap: () => controller.clearFieldError('username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Username tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Full Name
                      CustomTextField(
                        controller: _fullNameController,
                        labelText: 'Nama Lengkap',
                        hintText: 'Nama Lengkap',
                        prefixIcon: Icons.person_outline,
                        errorText: controller.getFieldError('full_name'),
                        onTap: () => controller.clearFieldError('full_name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Email
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        hintText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        errorText: controller.getFieldError('email'),
                        onTap: () => controller.clearFieldError('email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email tidak boleh kosong';
                          }
                          if (!GetUtils.isEmail(value)) {
                            return 'Email tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Phone
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'No. Ponsel',
                        hintText: 'No. Ponsel',
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        errorText: controller.getFieldError('phone'),
                        onTap: () => controller.clearFieldError('phone'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nomor ponsel tidak boleh kosong';
                          }
                          if (!GetUtils.isPhoneNumber(value)) {
                            return 'Nomor ponsel tidak valid';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password
                      CustomTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword.value,
                        errorText: controller.getFieldError('password'),
                        onTap: () => controller.clearFieldError('password'),
                        suffixIcon: Obx(
                          () => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              _obscurePassword.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: _obscurePassword.toggle,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Password Confirmation
                      CustomTextField(
                        controller: _passwordConfirmationController,
                        labelText: 'Konfirmasi Password',
                        hintText: 'Konfirmasi Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePasswordConfirmation.value,
                        errorText:
                            controller.getFieldError('password_confirmation'),
                        onTap: () => controller.clearFieldError(
                          'password_confirmation',
                        ),
                        suffixIcon: Obx(
                          () => IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 40,
                              minHeight: 40,
                            ),
                            icon: Icon(
                              _obscurePasswordConfirmation.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            onPressed: _obscurePasswordConfirmation.toggle,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Konfirmasi password tidak boleh kosong';
                          }
                          if (value != _passwordController.text) {
                            return 'Password tidak cocok';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 32),

                      // Register Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading ? null : _handleRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _handleLogin,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Masuk',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
