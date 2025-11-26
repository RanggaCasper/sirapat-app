import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

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
  final _obscurePassword = true.obs;
  final _obscurePasswordConfirmation = true.obs;

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      controller.register(
        nip: _nipController.text,
        username: _usernameController.text,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
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
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
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
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
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
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.account_balance,
                                  size: (logoSize * 0.6).clamp(35.0, 90.0),
                                  color: AppColors.iconPrimary,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Title
                        Text(
                          'SiRapat',
                          style: TextStyle(
                            fontFamily: 'workSans',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.titleDark,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          'Sistem Rapat Digital',
                          style: TextStyle(
                            fontFamily: 'workSans',
                            fontSize: 13,
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),

                        const SizedBox(height: 28),

                        // NIP Input
                        Obx(
                          () => TextFormField(
                            controller: _nipController,
                            keyboardType: TextInputType.number,
                            onChanged: (_) => controller.clearFieldError('nip'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'NIP',
                              hintText: 'Nomor Induk Pegawai',
                              errorText: controller.getFieldError('nip'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: controller.getFieldError('nip') != null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: controller.getFieldError('nip') != null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'NIP tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Username Input
                        Obx(
                          () => TextFormField(
                            controller: _usernameController,
                            onChanged: (_) =>
                                controller.clearFieldError('username'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Username',
                              hintText: 'Username',
                              errorText: controller.getFieldError('username'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('username') !=
                                          null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('username') !=
                                          null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Nama Lengkap Input
                        Obx(
                          () => TextFormField(
                            controller: _fullNameController,
                            onChanged: (_) =>
                                controller.clearFieldError('full_name'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Nama Lengkap',
                              hintText: 'Nama Lengkap',
                              errorText: controller.getFieldError('full_name'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('full_name') !=
                                          null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('full_name') !=
                                          null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama lengkap tidak boleh kosong';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email Input
                        Obx(
                          () => TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) =>
                                controller.clearFieldError('email'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'Email',
                              errorText: controller.getFieldError('email'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('email') != null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('email') != null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
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
                        ),

                        const SizedBox(height: 20),

                        // Phone Input
                        Obx(
                          () => TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            onChanged: (_) =>
                                controller.clearFieldError('phone'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'No. Ponsel',
                              hintText: 'No. Ponsel',
                              errorText: controller.getFieldError('phone'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('phone') != null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('phone') != null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
                              ),
                            ),
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
                        ),

                        const SizedBox(height: 20),

                        // Password Input
                        Obx(
                          () => TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword.value,
                            onChanged: (_) =>
                                controller.clearFieldError('password'),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Password',
                              errorText: controller.getFieldError('password'),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.iconSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _obscurePassword.value =
                                      !_obscurePassword.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('password') !=
                                          null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError('password') !=
                                          null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
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
                        ),

                        const SizedBox(height: 20),

                        // Password Confirmation Input
                        Obx(
                          () => TextFormField(
                            controller: _passwordConfirmationController,
                            obscureText: _obscurePasswordConfirmation.value,
                            onChanged: (_) => controller.clearFieldError(
                              'password_confirmation',
                            ),
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              hintText: 'Konfirmasi Password',
                              errorText: controller.getFieldError(
                                'password_confirmation',
                              ),
                              labelStyle: const TextStyle(fontSize: 14),
                              hintStyle: const TextStyle(fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.iconPrimary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePasswordConfirmation.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.iconSecondary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  _obscurePasswordConfirmation.value =
                                      !_obscurePasswordConfirmation.value;
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError(
                                            'password_confirmation',
                                          ) !=
                                          null
                                      ? Colors.red
                                      : AppColors.borderLight,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color:
                                      controller.getFieldError(
                                            'password_confirmation',
                                          ) !=
                                          null
                                      ? Colors.red
                                      : AppColors.iconPrimary,
                                  width: 2,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 2,
                                ),
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
                        ),

                        const SizedBox(height: 32),

                        // Register Button
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: controller.isLoading
                                  ? null
                                  : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: AppColors.borderLight,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: controller.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Daftar',
                                      style: TextStyle(
                                        fontFamily: 'workSans',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                fontFamily: 'workSans',
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

                        const SizedBox(height: 24),
                      ],
                    ),
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
