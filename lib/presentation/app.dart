import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_colors.dart';
import 'package:sirapat_app/presentation/controllers/auth_binding.dart';
import 'package:sirapat_app/presentation/controllers/division_binding.dart';
import 'package:sirapat_app/presentation/pages/splash_page.dart';
import 'package:sirapat_app/presentation/pages/login_page.dart';
import 'package:sirapat_app/presentation/pages/register_page.dart';
import 'package:sirapat_app/presentation/pages/forgot_password_page.dart';
import 'package:sirapat_app/presentation/pages/home_page.dart';
import 'package:sirapat_app/presentation/pages/division_page.dart';
import 'package:sirapat_app/presentation/widgets/custom_notification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sirapat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
        ),
      ),
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const CustomNotification(),
          ],
        );
      },
      initialRoute: '/',
      initialBinding: AuthBinding(),
      getPages: [
        GetPage(
          name: '/',
          page: () => const SplashPage(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/register',
          page: () => RegisterPage(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/forgot-password',
          page: () => ForgotPasswordPage(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/home',
          page: () => const HomePage(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: '/divisions',
          page: () => const DivisionPage(),
          binding: DivisionBinding(),
        ),
      ],
    );
  }
}
