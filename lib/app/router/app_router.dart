import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/attendance/presentation/providers/employee_attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' show authProvider;
import '../../features/dashboard/dashboard_admin_page.dart';
import '../../features/dashboard/dashboard_employee_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/activation_codes/presentation/pages/generate_activation_code_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
final appRouterProvider = Provider<GoRouter>((ref) {

  return GoRouter(
    redirect: (context, state) {
      final user = ref.read(authProvider).user;

      final isLoggedIn = user != null;

      final publicRoutes = [
        '/login',
        '/register',
        '/email-verification',
      ];

      if (!isLoggedIn && !publicRoutes.contains(state.matchedLocation)) {
        return '/login';
      }

      return null;
    },
initialLocation: '/',

    routes: [
GoRoute(
path: '/',
redirect: (context, state) => '/login',
),
GoRoute(
path: '/login',
builder: (context, state) => const LoginPage(),
),
GoRoute(
path: '/register',
builder: (context, state) => const RegisterPage(),
),
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const EmployeeAttendancePage(),
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
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),
GoRoute(
path: '/employees',
builder: (context, state) => const EmployeesPage(),
),
GoRoute(
path: '/activation-codes/generate',
  builder: (context, state) => const ActivationCodesPage(),),
],
);
});