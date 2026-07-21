import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../features/permissions/presentation/pages/admin_permissions_page.dart';
import '../../features/permissions/presentation/pages/permissions_page.dart';
import '../../features/attendance/presentation/pages/work_schedules_page.dart';

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
        path: '/login',
        builder: (context, state) => const LoginPage(),
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
    ],
  );
});