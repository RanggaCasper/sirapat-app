import 'package:get/get.dart';
import 'package:sirapat_app/app/routes/app_routes.dart';
import 'package:sirapat_app/presentation/controllers/auth_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_minute_binding.dart';
import 'package:sirapat_app/presentation/controllers/participant_binding.dart';
import 'package:sirapat_app/presentation/controllers/user_binding.dart';
import 'package:sirapat_app/presentation/controllers/division_binding.dart';
import 'package:sirapat_app/presentation/controllers/meeting_binding.dart';
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
import 'package:sirapat_app/presentation/features/employee/pages/employee_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/detail_meet_page.dart';
import 'package:sirapat_app/presentation/features/employee/pages/history_meet_page.dart';

/// Application pages configuration
class AppPages {
  static final List<GetPage> pages = [
    // Splash
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      binding: AuthBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.login,
      page: () => LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => RegisterPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => ForgotPasswordPage(),
      binding: AuthBinding(),
    ),

    // Profile (with AuthBinding for accessing currentUser)
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
      binding: AuthBinding(),
    ),

    // Master Dashboard
    GetPage(
      name: AppRoutes.masterDashboard,
      page: () => const MasterPage(),
      bindings: [AuthBinding(), DivisionBinding(), UserBinding()],
    ),

    // Admin Dashboard
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminPage(),
      bindings: [AuthBinding(), MeetingBinding()],
    ),
    GetPage(
      name: AppRoutes.adminCreateMeeting,
      page: () => const CreateMeetingPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.adminAllMeetings,
      page: () => const MeetingsPage(),
      binding: MeetingBinding(),
    ),
    GetPage(
      name: AppRoutes.adminMeetingDetail,
<<<<<<< HEAD
      page: () => MeetingDetailPage(meetingId: Get.arguments as int),
      bindings: [MeetingBinding(), ParticipantBinding()],
=======
      page: () => MeetingDetailPage(meeting: Get.arguments as Meeting),
      bindings: [
        MeetingBinding(),
        ParticipantBinding(),
        MeetingMinuteBinding(),
      ],
>>>>>>> 582d619f68873416dbcb51ecd7b3dde9a9f4180a
    ),
    // Employee Dashboard
    GetPage(
      name: AppRoutes.employeeDashboard,
      page: () => const EmployeePage(),
      bindings: [AuthBinding(), MeetingBinding()],
    ),
    GetPage(
      name: AppRoutes.employeeDetailMeeting,
      page: () => const DetailMeetPage(),
      bindings: [MeetingBinding(), ParticipantBinding()],
    ),
    GetPage(
      name: AppRoutes.employeeHistoryMeeting,
      page: () => const HistoryMeetPage(),
      binding: MeetingBinding(),
    ),
  ];
}
