import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/work_timer_service.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../attendance/presentation/providers/attendance_provider.dart';
class DashboardEmployeePage extends ConsumerStatefulWidget {
  const DashboardEmployeePage({super.key});

  @override
  ConsumerState<DashboardEmployeePage> createState() =>
      _DashboardEmployeePageState();
}

class _DashboardEmployeePageState extends ConsumerState<DashboardEmployeePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(attendanceProvider.notifier).loadTodayRecord();
    });
  }
  String _formatLiveDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  String _formatWorkedMinutes(int minutes) {
    if (minutes <= 0) return '0 س';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (mins == 0) return '$hours س';
    return '$hours س و $mins د';
  }

  String _statusText(String? status) {
    switch (status) {
      case 'checked_in':
        return 'داخل الدوام';

      case 'late':
        return 'تأخير غير معتمد';

      case 'approved_late':
        return 'تأخير معتمد';

      case 'partially_approved_late':
        return 'تأخير جزئي';

      case 'checked_out':
        return 'مكتمل';

      case 'early_leave':
        return 'خروج مبكر';

      case 'late_checked_out':
        return 'مكتمل مع تأخير';

      case 'late_and_early_leave':
        return 'تأخير وخروج مبكر';

      case 'hours_incomplete':
        return 'ساعات ناقصة';

      case 'hours_completed':
        return 'ساعات مكتملة';

      case 'hours_completed_with_overtime':
        return 'أوفر تايم';

      default:
        return 'لم يبدأ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final attendanceState = ref.watch(attendanceProvider);
    final todayRecord = attendanceState.todayRecord;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'لوحة الموظف',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout_rounded),
              onPressed: () async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('logout pressed')),
                );
                await ref.read(authProvider.notifier).signOut();
                if (!context.mounted) return;
                context.go('/login');
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
                      Icons.person_rounded,
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
                          'مرحباً بك',
                          style: TextStyle(
                            color: Color(0xFFE0F2FE),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user?.fullName ?? 'موظف WorkPulse',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الدور: ${user?.role ?? 'employee'}',
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
                  child: _QuickActionCard(
                    title: 'تسجيل حضور',
                    subtitle: 'بداية الدوام',
                    icon: Icons.login_rounded,
                    onTap: () {
                      context.push('/attendance').then((_) {
                        ref.read(attendanceProvider.notifier).loadTodayRecord();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionCard(
                    title: 'تسجيل انصراف',
                    subtitle: 'نهاية الدوام',
                    icon: Icons.logout_rounded,
                    onTap: () {
                      context.push('/attendance').then((_) {
                        ref.read(attendanceProvider.notifier).loadTodayRecord();
                      });
                    },                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: StreamBuilder<Duration>(
                    stream: WorkTimerService.instance.durationStream,
                    builder: (context, snapshot) {
                      final liveDuration = snapshot.data ?? Duration.zero;

                      final value = todayRecord?.checkInAt != null &&
                          todayRecord?.checkOutAt == null
                          ? _formatLiveDuration(liveDuration)
                          : _formatWorkedMinutes(todayRecord?.workedMinutes ?? 0);

                      return _InfoCard(
                        title: 'ساعات اليوم',
                        value: value,
                        icon: Icons.access_time_rounded,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _InfoCard(
                    title: 'حالة اليوم',
                    value: _statusText(todayRecord?.status),
                    icon: Icons.event_available_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'الخدمات',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 14),

            _ServiceTile(
              title: 'سجل الحضور الشهري',
              subtitle: 'عرض الحضور والانصراف لهذا الشهر',
              icon: Icons.calendar_month_rounded,
              onTap: () => context.push('/attendance/monthly'), // ✅
            ),
            _ServiceTile(
              title: 'طلب إجازة',
              subtitle: 'إرسال طلب إجازة للإدارة',
              icon: Icons.beach_access_rounded,
              onTap: () {},
            ),
            _ServiceTile(
              title: 'طلب إذن',
              subtitle: 'طلب تأخير أو خروج مبكر',
              icon: Icons.schedule_send_rounded,
              onTap: () => context.push('/permissions'), // ✅
            ),
            _ServiceTile(
              title: 'طلب تعديل بصمة',
              subtitle: 'في حال نسيان تسجيل الدخول أو الخروج',
              icon: Icons.edit_calendar_rounded,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
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
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 34,
                color: const Color(0xFF0F766E),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFF59E0B),
            size: 30,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
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
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFECFDF5),
          child: Icon(
            icon,
            color: const Color(0xFF0F766E),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}