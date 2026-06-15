import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/attendance/presentation/pages/employee_attendance_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/dashboard/dashboard_admin_page.dart';
import '../../features/dashboard/dashboard_employee_page.dart';
import '../../features/employees/presentation/pages/employees_page.dart';
import '../../features/activation_codes/presentation/pages/generate_activation_code_page.dart';
import '../../features/auth/presentation/pages/email_verification_page.dart';
import '../../features/attendance/presentation/pages/monthly_attendance_page.dart';
import '../../features/permissions/presentation/providers/permissions_provider.dart';
final appRouterProvider = Provider<GoRouter>((ref) {
  // ✅ نراقب تغييرات authProvider لإعادة التوجيه تلقائياً
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: null,

    redirect: (context, state) {
      final user = authState.user;
      final isLoggedIn = user != null;
      final currentPath = state.matchedLocation;

      // ✅ المسارات العامة التي لا تحتاج تسجيل دخول
      final publicRoutes = ['/login', '/register', '/email-verification'];
      final isPublicRoute = publicRoutes.contains(currentPath);

      // ✅ المسارات المخصصة للأدمن فقط
      final adminRoutes = ['/admin', '/employees', '/activation-codes/generate'];
      final isAdminRoute = adminRoutes.contains(currentPath);

      // ✅ المسارات المخصصة للموظف فقط
      final employeeRoutes = ['/employee', '/attendance'];
      final isEmployeeRoute = employeeRoutes.contains(currentPath);

      // 1. غير مسجل دخول → أرسله للـ login
      if (!isLoggedIn && !isPublicRoute) {
        return '/login';
      }

      // 2. مسجل دخول وعلى صفحة عامة → أرسله للـ dashboard الصحيح
      if (isLoggedIn && isPublicRoute) {
        return user.role == 'admin' ? '/admin' : '/employee';
      }

      // 3. موظف يحاول الوصول لصفحة الأدمن → أرسله لصفحته
      if (isLoggedIn && isAdminRoute && user.role != 'admin') {
        return '/employee';
      }

      // 4. أدمن يحاول الوصول لصفحة الموظف → أرسله لصفحته
      if (isLoggedIn && isEmployeeRoute && user.role == 'admin') {
        return '/admin';
      }

      return null;
    },

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
        path: '/permissions',
        builder: (context, state) => const PermissionsPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/email-verification',
        builder: (context, state) => const EmailVerificationPage(),
      ),

      // ✅ مسارات الأدمن
      GoRoute(
        path: '/admin',
        builder: (context, state) => const DashboardAdminPage(),
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
        path: '/attendance/monthly',
        builder: (context, state) => const MonthlyAttendancePage(),
      ),
      // ✅ مسارات الموظف
      GoRoute(
        path: '/employee',
        builder: (context, state) => const DashboardEmployeePage(),
      ),
      GoRoute(
        path: '/attendance',  // ✅ هذا كان ناقصاً وسيسبب crash
        builder: (context, state) => const EmployeeAttendancePage(),
      ),
    ],
  );
});