import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/corrections/presentation/pages/admin_corrections_page.dart';
import '../../features/corrections/presentation/pages/corrections_page.dart';
import '../../features/attendance/presentation/pages/monthly_attendance_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/attendance/presentation/pages/employee_attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/dashboard/dashboard_admin_page.dart';
import '../../features/dashboard/dashboard_employee_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/activation_codes/presentation/pages/generate_activation_code_page.dart';
import '../../features/leaves/presentation/pages/admin_carry_forward_page.dart';
import '../../features/leaves/presentation/pages/admin_leave_balances_page.dart';
import '../../features/leaves/presentation/pages/admin_leaves_page.dart';
import '../../features/leaves/presentation/pages/leaves_page.dart';
import '../../features/notifications/presentation/pages/admin_announcement_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/permissions/presentation/pages/admin_permissions_page.dart';
import '../../features/permissions/presentation/pages/permissions_page.dart';
import '../../features/attendance/presentation/pages/work_schedules_page.dart';
import '../../features/attendance/presentation/pages/admin_today_attendance_page.dart';
import '../../features/reports/presentation/admin_corrections_report_page.dart';
import '../../features/reports/presentation/admin_daily_attendance_summary_page.dart';
import '../../features/reports/presentation/admin_early_leave_report_page.dart';
import '../../features/reports/presentation/admin_geofence_report_page.dart';
import '../../features/reports/presentation/admin_late_report_page.dart';
import '../../features/reports/presentation/admin_leaves_report_page.dart';
import '../../features/reports/presentation/admin_monthly_attendance_by_employee_report_page.dart';
import '../../features/reports/presentation/admin_permissions_report_page.dart';
import '../../features/reports/presentation/admin_reports_page.dart';
import '../../features/reports/presentation/admin_today_violations_page.dart';
import '../../features/reports/presentation/admin_work_hours_report_page.dart';

final appRouterProvider = Provider.autoDispose<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final user = authState.user;
      final isLoggedIn = user != null;
      final currentPath = state.matchedLocation;

      const publicRoutes = ['/login', '/register', '/email-verification'];
      final isPublicRoute = publicRoutes.contains(currentPath);

      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      if (isLoggedIn && isPublicRoute) {
        return user!.role == 'admin' ? '/admin' : '/employee';
      }

      return null;
    },

    routes: [
      GoRoute(
        path: '/admin/corrections',
        builder: (context, state) => const AdminCorrectionsPage(),
      ),

      GoRoute(
        path: '/corrections',
        builder: (context, state) => const CorrectionsPage(),
      ),

      GoRoute(
        path: '/admin/attendance-today',
        builder: (context, state) => const AdminTodayAttendancePage(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsPage(),
      ),
      GoRoute(
        path: '/admin/reports/late',
        builder: (context, state) => const AdminLateReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/early-leave',
        builder: (context, state) => const AdminEarlyLeaveReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/work-hours',
        builder: (context, state) => const AdminWorkHoursReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/daily-summary',
        builder: (context, state) => const AdminDailyAttendanceSummaryPage(),
      ),
      GoRoute(
        path: '/admin/reports/violations',
        builder: (context, state) => const AdminTodayViolationsPage(),
      ),
      GoRoute(
        path: '/admin/reports/leaves',
        builder: (context, state) => const AdminLeavesReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/monthly-attendance-by-employee',
        builder: (context, state) => const AdminMonthlyAttendanceByEmployeeReportPage(),
      ),
      GoRoute(
        path: '/leaves',
        builder: (context, state) => const LeavesPage(),
      ),
      GoRoute(
        path: '/admin/leaves',
        builder: (context, state) => const AdminLeavesPage(),
      ),
      GoRoute(
        path: '/admin/reports/permissions',
        builder: (context, state) => const AdminPermissionsReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/geofence',
        builder: (context, state) => const AdminGeofenceReportPage(),
      ),
      GoRoute(
        path: '/admin/reports/corrections',
        builder: (context, state) => const AdminCorrectionsReportPage(),
      ),
      GoRoute(
        path: '/admin/leave-balances',
        builder: (context, state) => const AdminLeaveBalancesPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/admin/carry-forward',
        name: 'admin-carry-forward',
        builder: (context, state) => const AdminCarryForwardPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const DashboardAdminPage(),
      ),
      GoRoute(
        path: '/employee',
        builder: (context, state) => const DashboardEmployeePage(),
      ),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const EmployeeAttendancePage(),
      ),
      GoRoute(
        path: '/attendance/monthly',
        builder: (context, state) => const MonthlyAttendancePage(),
      ),
      GoRoute(
        path: '/employees',
        builder: (context, state) => const EmployeesPage(),
      ),
      GoRoute(
        path: '/activation-codes/generate',
        builder: (context, state) => const ActivationCodesPage(),
      ),
      GoRoute(
        path: '/admin/permissions',
        builder: (context, state) => const AdminPermissionsPage(),
      ),
      GoRoute(
        path: '/admin/work-schedules',
        builder: (context, state) => const WorkSchedulesPage(),
      ),
      GoRoute(
        path: '/permissions',
        builder: (context, state) => const PermissionsPage(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/admin/announcements',
        builder: (context, state) => const AdminAnnouncementPage(),
      ),
    ],
  );
});