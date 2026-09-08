import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../employees/presentation/providers/employees_provider.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../reports/presentation/providers/reports_provider.dart';


class DashboardAdminPage extends ConsumerStatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  ConsumerState<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends ConsumerState<DashboardAdminPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeesProvider.notifier).loadEmployees();
      ref.read(reportsProvider.notifier).loadAdminTodaySummary();
      ref.read(reportsProvider.notifier).loadAdminTodayViolations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final employeesState = ref.watch(employeesProvider);
    final reportsState = ref.watch(reportsProvider);
    final summary = reportsState.adminTodaySummary;
    final violations = reportsState.todayViolations; // تعريف صريح واحد
    final employeesCount = employeesState.employees.length;
    final pendingEmployeesCount = employeesState.employees
        .where((employee) => employee.isActive != true)
        .length;
    final violationsCount = violations.length; // الآن مستخدم فعليا
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'لوحة الإدارة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(employeesProvider.notifier).loadEmployees();
              ref.read(reportsProvider.notifier).loadAdminTodaySummary();
              ref.read(reportsProvider.notifier).loadAdminTodayViolations();
            },
          ),
          IconButton(
              tooltip: 'تسجيل الخروج',
              icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
              }
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF155E75),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مرحباً بك في WorkPulse',
                          style: TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.fullName ?? 'مدير النظام',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الدور: ${user?.role ?? 'admin'}',
                          style: const TextStyle(
                            color: Color(0xFFCCFBF1),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    title: 'الموظفون',
                    value: employeesCount.toString(),
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF0F766E),
                  ),
                ),

                const SizedBox(width: 14),
                Expanded(
                  child: _AdminStatCard(
                    title: 'بانتظار التفعيل',
                    value: pendingEmployeesCount.toString(),
                    icon: Icons.person_add_disabled_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _AdminStatCard(
                    title: 'حضور اليوم',
                    value: '${summary?.checkedInNow ?? 0}',
                    icon: Icons.login_rounded,
                    color: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AdminStatCard(
                    title: 'تأخير اليوم',
                    value: '${summary?.lateToday ?? 0}',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
            const Text(
              'مخالفات اليوم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            _ViolationsEntryTile(
              violationsCount: violationsCount,
              onTap: () => context.push('/admin/reports/violations'),
            ),
            const SizedBox(height: 26),


            const Text(
              'إدارة النظام',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 14),

            _AdminActionTile(
              title: 'إدارة الموظفين',
              subtitle: 'عرض الموظفين وتفعيل أو تعطيل الحسابات',
              icon: Icons.people_alt_outlined,
              onTap: () {
                context.push('/employees');
              },
            ),
            _AdminActionTile(
              title: 'توليد كود تفعيل',
              subtitle: 'إنشاء كود تسجيل لموظف جديد',
              icon: Icons.vpn_key_rounded,
              onTap: () {
                context.push('/activation-codes/generate');
              },
            ),

            _AdminActionTile(
              title: 'إعدادات الدوام',
              subtitle: 'إدارة جداول الدوام، السماحية، ونوع الدوام',
              icon: Icons.schedule_rounded,
              onTap: () {
                context.push('/admin/work-schedules');
              },
            ),

            _AdminActionTile(
              title: 'الحضور اليومي',
              subtitle: 'متابعة حضور وانصراف الموظفين',
              icon: Icons.fact_check_rounded,
              onTap: () {
                context.push('/admin/attendance-today');
              },
            ),
            _AdminActionTile(
              title: 'طلبات الإجازات',
              subtitle: 'مراجعة واعتماد أو رفض طلبات الإجازة',
              icon: Icons.beach_access_rounded,
              onTap: () {
                context.push('/admin/leaves');
              },
            ),
            _AdminActionTile(
              title: 'أرصدة الإجازات',
              subtitle: 'ضبط رصيد الإجازات للموظفين',
              icon: Icons.account_balance_wallet_rounded,
              onTap: () {
                context.push('/admin/leave-balances');
              },
            ),
            _AdminActionTile(
              title: 'طلبات الأذونات',
              subtitle: 'مراجعة الإجازات والأذونات وتعديل البصمات',
              icon: Icons.assignment_late_rounded,
              onTap: () {context.push('/admin/permissions');},
            ),
            _AdminActionTile(
              title: 'طلبات تعديل البصمات',
              subtitle: 'مراجعة واعتماد أو رفض طلبات تعديل الحضور والانصراف',
              icon: Icons.edit_calendar_rounded,
              onTap: () {
                context.push('/admin/corrections');
              },
            ),
            _AdminActionTile(
              title: 'التقارير',
              subtitle: 'الدخول إلى مركز تقارير الإدارة (10 تقارير)',
              icon: Icons.bar_chart_rounded,
              onTap: () {
                context.push('/admin/reports');
              },
            ),
          ],
        ),
      ),
    );
  }
}
class _ViolationsEntryTile extends StatelessWidget {
  const _ViolationsEntryTile({
    required this.violationsCount,
    required this.onTap,
  });

  final int violationsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasViolations = violationsCount > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hasViolations
                  ? 'عدد مخالفات اليوم: $violationsCount'
                  : 'لا توجد مخالفات اليوم',
              style: TextStyle(
                color: hasViolations
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF0F766E),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: const Text('عرض الكل'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 9,
        ),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFECFDF5),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Color(0xFF0F766E),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(
          icon,
          color: const Color(0xFF0F766E),
        ),
        onTap: onTap,
      ),
    );
  }
}