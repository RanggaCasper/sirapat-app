import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sirapat_app/app/config/app_theme.dart';
import 'package:sirapat_app/presentation/controllers/auth_binding.dart';
import 'package:sirapat_app/presentation/controllers/user_binding.dart';
import 'package:sirapat_app/presentation/controllers/division_binding.dart';
import 'package:sirapat_app/presentation/features/admin/pages/admin_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/create_meeting_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/meetings_page.dart';
import 'package:sirapat_app/presentation/features/admin/pages/meeting_detail_page.dart';
import 'package:sirapat_app/presentation/features/splash/pages/splash_page.dart';
import 'package:sirapat_app/presentation/features/auth/pages/login_page.dart';
import 'package:sirapat_app/presentation/features/auth/pages/register_page.dart';
import 'package:sirapat_app/presentation/features/auth/pages/forgot_password_page.dart';
import 'package:sirapat_app/presentation/features/master/pages/master_page.dart';
import 'package:sirapat_app/presentation/features/profile/pages/profile_page.dart';
import 'package:sirapat_app/presentation/shared/widgets/custom_notification.dart';

import 'package:sirapat_app/presentation/features/employee/pages/employee_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/history/history_meet_page.dart';
import 'package:sirapat_app/domain/entities/meeting.dart';

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
          name: '/profile',
          page: () => const ProfilePage(),
          binding: AuthBinding(),
        ),

        // Master
        GetPage(name: '/master-dashboard', page: () => const MasterPage()),
        GetPage(
          name: '/divisions',
          page: () => const MasterPage(), // Divisions integrated in Master Page
          binding: DivisionBinding(),
        ),
        GetPage(
          name: '/users',
          page: () => const MasterPage(), // Users integrated in Master Page
          binding: UserBinding(),
        ),

        // Admin
        GetPage(name: '/admin-dashboard', page: () => const AdminPage()),
        GetPage(
          name: '/admin-create-meeting',
          page: () => const CreateMeetingPage(),
        ),
        GetPage(
          name: '/admin-all-meetings',
          page: () => const AllMeetingsPage(),
        ),
        GetPage(
          name: '/admin-meeting-detail',
          page: () => MeetingDetailPage(meeting: Get.arguments as Meeting),
        ),

        // Employee
        GetPage(name: '/employee-dashboard', page: () => const EmployeePage()),
        GetPage(
          name: '/employee-detail-meeting',
          page: () => const DetailMeetPage(),
        ),
        GetPage(
          name: '/employee-history-meeting',
          page: () => const HistoryMeetPage(),
        ),
      ],
    );
  }
}
