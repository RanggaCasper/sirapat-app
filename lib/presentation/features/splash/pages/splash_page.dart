import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_constants.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    debugPrint('[SplashPage] Starting authentication check...');

    // Wait for splash animation
    await Future.delayed(AppConstants.splashDuration);

    final authController = Get.find<AuthController>();

    // Verify authentication from server
    debugPrint('[SplashPage] Verifying authentication...');
    final isAuthenticated = await authController.verifyAuthentication();

    debugPrint('[SplashPage] Authentication result: $isAuthenticated');
    debugPrint(
      '[SplashPage] Current user: ${authController.currentUser?.fullName}',
    );

    if (!mounted) return;

    if (isAuthenticated && authController.currentUser != null) {
      final role = authController.currentUser!.role?.toLowerCase();
      debugPrint('[SplashPage] User role: $role');

      // Navigate based on role
      switch (role) {
        case 'master':
          debugPrint('[SplashPage] Navigating to master dashboard');
          Get.offAllNamed('/master-dashboard');
          break;
        case 'admin':
          debugPrint('[SplashPage] Navigating to admin dashboard');
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'employee':
          debugPrint('[SplashPage] Navigating to employee dashboard');
          Get.offAllNamed('/employee-dashboard');
          break;
        default:
          debugPrint('[SplashPage] Invalid role, navigating to login');
          Get.offAllNamed('/login');
      }
    } else {
      debugPrint('[SplashPage] Not authenticated, navigating to login');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo dari Assets
              SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback logo jika tidak ditemukan
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
                        Icons.account_balance,
                        size: 120,
                        color: Color(0xFF1E5BA8),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SiRapat',
                style: TextStyle(
                  fontFamily: 'workSans',
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3C72),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sistem Rapat Digital',
                style: TextStyle(
                  fontFamily: 'workSans',
                  fontSize: 16,
                  color: Color(0xFF1E3C72),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E5BA8)),
                strokeWidth: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
