import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    print('[SplashPage] Starting authentication check...');

    // Wait for splash animation
    await Future.delayed(const Duration(seconds: 2));

    final authController = Get.find<AuthController>();

    // Verify authentication from server
    print('[SplashPage] Verifying authentication...');
    final isAuthenticated = await authController.verifyAuthentication();

    print('[SplashPage] Authentication result: $isAuthenticated');
    print('[SplashPage] Current user: ${authController.currentUser?.fullName}');

    if (!mounted) return;

    if (isAuthenticated && authController.currentUser != null) {
      final role = authController.currentUser!.role?.toLowerCase();
      print('[SplashPage] User role: $role');

      // Navigate based on role
      switch (role) {
        case 'master':
          print('[SplashPage] Navigating to master dashboard');
          Get.offAllNamed('/master-dashboard');
          break;
        case 'admin':
          print('[SplashPage] Navigating to admin dashboard');
          Get.offAllNamed('/admin-dashboard');
          break;
        case 'employee':
          print('[SplashPage] Navigating to employee dashboard');
          Get.offAllNamed('/employee-dashboard');
          break;
        default:
          print('[SplashPage] Invalid role, navigating to login');
          Get.offAllNamed('/login');
      }
    } else {
      print('[SplashPage] Not authenticated, navigating to login');
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
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
    );
  }
}
