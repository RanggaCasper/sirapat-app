import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_theme.dart';
import 'package:sirapat_app/app/routes/app_routes.dart';
import 'package:sirapat_app/app/routes/app_pages.dart';
import 'package:sirapat_app/presentation/controllers/auth_binding.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Sirapat App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      builder: (context, child) {
        return Stack(
          children: [
            child ?? const SizedBox.shrink(),
            const CustomNotification(),
          ],
        );
      },
      initialRoute: AppRoutes.splash,
      initialBinding: AuthBinding(),
      getPages: AppPages.pages,
    );
  }
}
