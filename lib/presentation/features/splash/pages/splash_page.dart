import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/presentation/controllers/auth_controller.dart';

class SplashPage extends GetView<AuthController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate after checking auth status
    Future.delayed(const Duration(seconds: 2), () {
      if (controller.isLoggedIn) {
        Get.offAllNamed('/home');
      } else {
        Get.offAllNamed('/login');
      }
    });

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
