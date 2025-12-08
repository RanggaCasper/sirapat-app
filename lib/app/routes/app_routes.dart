/// Application routes constants
class AppRoutes {
  // Root
  static const String splash = '/';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Common
  static const String profile = '/profile';

  // Master
  static const String masterDashboard = '/master-dashboard';
  static const String divisions = '/divisions';
  static const String users = '/users';

  // Admin
  static const String adminDashboard = '/admin-dashboard';
  static const String adminCreateMeeting = '/admin-create-meeting';
  static const String adminAllMeetings = '/admin-all-meetings';
  static const String adminMeetingDetail = '/admin-meeting-detail';
  static const String adminInviteParticipant = '/admin-invite-participant';

  // Employee
  static const String employeeDashboard = '/employee-dashboard';
  static const String employeeDetailMeeting = '/employee-detail-meeting';
  static const String employeeHistoryMeeting = '/employee-history-meeting';
}
