import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordPage extends GetView<ForgotPasswordController> {
  ForgotPasswordPage({super.key});

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _obscurePassword = true.obs;
  final _obscurePasswordConfirmation = true.obs;

  void _handleSendOtp() {
    if (_emailController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Email tidak boleh kosong',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    controller.sendOtp(_emailController.text);
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      controller.resetPassword(
        email: _emailController.text,
        otp: _otpController.text,
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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background Pattern
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/pattern.png',
              height: 330,
              width: double.infinity,
              fit: BoxFit.cover,
              color: Colors.white.withOpacity(0.92),
              colorBlendMode: BlendMode.dstATop,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 330,
                  width: double.infinity,
                  color: AppColors.background,
                );
              },
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Header (Fixed - tidak ikut scroll)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Logo
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              child: Icon(
                                Icons.account_balance,
                                size: 70,
                                color: AppColors.iconPrimary,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Lupa Password',
                        style: TextStyle(
                          fontFamily: 'workSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.titleDark,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          'Masukkan email Anda dan kami akan mengirimkan OTP untuk reset password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textLight,
                            height: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),

                // Form Fields (Scrollable)
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),

                          // Email Input
                          Obx(
                            () => TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              enabled: !controller.isOtpSent.value,
                              onChanged: (_) =>
                                  controller.clearFieldError('email'),
                              style: const TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Masukkan email Anda',
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
                                        controller.getFieldError('email') !=
                                            null
                                        ? Colors.red
                                        : AppColors.borderLight,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        controller.getFieldError('email') !=
                                            null
                                        ? Colors.red
                                        : AppColors.iconPrimary,
                                    width: 2,
                                  ),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: AppColors.borderLight,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
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

                          // Send OTP Button (only show if OTP not sent)
                          Obx(
                            () => !controller.isOtpSent.value
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed:
                                              controller.isLoading.value ||
                                                  controller.retryAfter.value >
                                                      0
                                              ? null
                                              : _handleSendOtp,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                AppColors.iconPrimary,
                                            foregroundColor: Colors.white,
                                            disabledBackgroundColor:
                                                AppColors.borderLight,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: controller.isLoading.value
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : Text(
                                                  controller.retryAfter.value >
                                                          0
                                                      ? 'Coba lagi dalam ${controller.retryAfter.value}s'
                                                      : 'Kirim OTP',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          // OTP and Password Fields (shown after OTP sent)
                          Obx(
                            () => controller.isOtpSent.value
                                ? Column(
                                    children: [
                                      const SizedBox(height: 16),

                                      // OTP Input
                                      Obx(
                                        () => TextFormField(
                                          controller: _otpController,
                                          keyboardType: TextInputType.number,
                                          onChanged: (_) =>
                                              controller.clearFieldError('otp'),
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Kode OTP',
                                            hintText: 'Masukkan kode OTP',
                                            errorText: controller.getFieldError(
                                              'otp',
                                            ),
                                            labelStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            hintStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                            prefixIcon: Icon(
                                              Icons.security,
                                              color: AppColors.iconPrimary,
                                              size: 20,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    controller.getFieldError(
                                                          'otp',
                                                        ) !=
                                                        null
                                                    ? Colors.red
                                                    : AppColors.borderLight,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    controller.getFieldError(
                                                          'otp',
                                                        ) !=
                                                        null
                                                    ? Colors.red
                                                    : AppColors.iconPrimary,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 2,
                                                  ),
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Kode OTP tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Password Input
                                      Obx(
                                        () => TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword.value,
                                          onChanged: (_) => controller
                                              .clearFieldError('password'),
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Password Baru',
                                            hintText: 'Masukkan password baru',
                                            errorText: controller.getFieldError(
                                              'password',
                                            ),
                                            labelStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            hintStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                    ? Icons
                                                          .visibility_off_outlined
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    controller.getFieldError(
                                                          'password',
                                                        ) !=
                                                        null
                                                    ? Colors.red
                                                    : AppColors.borderLight,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color:
                                                    controller.getFieldError(
                                                          'password',
                                                        ) !=
                                                        null
                                                    ? Colors.red
                                                    : AppColors.iconPrimary,
                                                width: 2,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 2,
                                                  ),
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Password tidak boleh kosong';
                                            }
                                            if (value.length < 6) {
                                              return 'Password minimal 6 karakter';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 16),

                                      // Password Confirmation Input
                                      Obx(
                                        () => TextFormField(
                                          controller:
                                              _passwordConfirmationController,
                                          obscureText:
                                              _obscurePasswordConfirmation
                                                  .value,
                                          onChanged: (_) =>
                                              controller.clearFieldError(
                                                'password_confirmation',
                                              ),
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Konfirmasi Password',
                                            hintText:
                                                'Konfirmasi password baru',
                                            errorText: controller.getFieldError(
                                              'password_confirmation',
                                            ),
                                            labelStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            hintStyle: const TextStyle(
                                              fontSize: 14,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
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
                                                _obscurePasswordConfirmation
                                                        .value
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: AppColors.iconSecondary,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                _obscurePasswordConfirmation
                                                        .value =
                                                    !_obscurePasswordConfirmation
                                                        .value;
                                              },
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: const BorderSide(
                                                    color: Colors.red,
                                                    width: 2,
                                                  ),
                                                ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Konfirmasi password tidak boleh kosong';
                                            }
                                            if (value !=
                                                _passwordController.text) {
                                              return 'Password tidak cocok';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                                      const SizedBox(height: 24),

                                      // Reset Password Button
                                      Obx(
                                        () => SizedBox(
                                          width: double.infinity,
                                          height: 48,
                                          child: ElevatedButton(
                                            onPressed:
                                                controller.isLoading.value
                                                ? null
                                                : _handleResetPassword,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.iconPrimary,
                                              foregroundColor: Colors.white,
                                              disabledBackgroundColor:
                                                  AppColors.borderLight,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              elevation: 0,
                                            ),
                                            child: controller.isLoading.value
                                                ? const SizedBox(
                                                    height: 24,
                                                    width: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                            Color
                                                          >(Colors.white),
                                                    ),
                                                  )
                                                : const Text(
                                                    'Reset Password',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),

                          const SizedBox(height: 24),

                          // Back to Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah ingat password? ',
                                style: TextStyle(
                                  color: AppColors.textMedium,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                onPressed: _handleLogin,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
