import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_text_field.dart';

class LoginPage extends GetView<AuthController> {
  LoginPage({super.key});

  final _nipController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final RxBool _obscurePassword = true.obs;

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      controller.login(
        _nipController.text.trim(),
        _passwordController.text,
      );
    }
  }

  void _handleForgotPassword() {
    Get.toNamed('/forgot-password');
  }

  void _handleRegister() {
    Get.toNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double logoSize = (size.width * 0.28).clamp(80.0, 140.0);

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Sistem Rapat Digital',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),

                      const SizedBox(height: 32),

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

                      // Password
                      Obx(
                        () => CustomTextField(
                          controller: _passwordController,
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscurePassword.value,
                          errorText: controller.getFieldError('password'),
                          onTap: () => controller.clearFieldError('password'),
                          suffixIcon: IconButton(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _handleForgotPassword,
                          child: Text(
                            'Lupa password?',
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      // Login Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed:
                                controller.isLoading ? null : _handleLogin,
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
                                    'Masuk',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              color: AppColors.textMedium,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: _handleRegister,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'Daftar',
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
