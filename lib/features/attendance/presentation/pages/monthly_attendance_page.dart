import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/attendance_provider.dart';
import '../../../../../core/utils/time_formatters.dart';
class MonthlyAttendancePage extends ConsumerStatefulWidget {
  const MonthlyAttendancePage({super.key});

  @override
  ConsumerState<MonthlyAttendancePage> createState() =>
      _MonthlyAttendancePageState();
}

class _MonthlyAttendancePageState
    extends ConsumerState<MonthlyAttendancePage> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(attendanceProvider.notifier)
          .loadMonthlyRecords(_selectedMonth);
    });
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
    ref
        .read(attendanceProvider.notifier)
        .loadMonthlyRecords(_selectedMonth);
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year &&
        _selectedMonth.month == now.month) return;

    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
    ref
        .read(attendanceProvider.notifier)
        .loadMonthlyRecords(_selectedMonth);
  }

  String _monthName(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatTime(String? value) {
    return formatDateTimeToTime12(value);
  }

  String _formatWorkedMinutes(int minutes) {
    if (minutes <= 0) return '0 س';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '$mins د';
    if (mins == 0) return '$hours س';
    return '$hours س $mins د';
  }

  // ✅ إحصائيات الشهر
  Map<String, dynamic> _calculateStats(List records) {
    int totalDays = records.length;
    int presentDays = records
        .where((r) => r.checkInAt != null && r.checkOutAt != null)
        .length;
    int incompleteDays = records
        .where((r) => r.checkInAt != null && r.checkOutAt == null)
        .length;
    int totalLateMinutes =
    records.fold(0, (sum, r) => sum + (r.lateMinutes as int));
    int totalWorkedMinutes =
    records.fold(0, (sum, r) => sum + (r.workedMinutes as int));

    return {
      'totalDays': totalDays,
      'presentDays': presentDays,
      'incompleteDays': incompleteDays,
      'totalLateMinutes': totalLateMinutes,
      'totalWorkedMinutes': totalWorkedMinutes,
    };
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'checked_in':
        return const Color(0xFF0284C7);

      case 'late':
        return const Color(0xFFDC2626);

      case 'approved_late':
        return const Color(0xFF0F766E);

      case 'partially_approved_late':
        return const Color(0xFFF59E0B);

      case 'checked_out':
        return const Color(0xFF0F766E);

      case 'early_leave':
        return const Color(0xFFEC4899);

      case 'late_checked_out':
        return const Color(0xFFF59E0B);

      case 'late_and_early_leave':
        return const Color(0xFFDC2626);

      case 'hours_incomplete':
        return const Color(0xFFEC4899);

      case 'hours_completed':
        return const Color(0xFF0F766E);

      case 'hours_completed_with_overtime':
        return const Color(0xFF7C3AED);

      default:
        return const Color(0xFF94A3B8);
    }
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
        return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final records = state.monthlyRecords;
    final stats = _calculateStats(records);
    final isCurrentMonth = _selectedMonth.year == DateTime.now().year &&
        _selectedMonth.month == DateTime.now().month;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'سجل الحضور الشهري',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(attendanceProvider.notifier)
              .loadMonthlyRecords(_selectedMonth);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ✅ مختار الشهر
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border:
                Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: const Color(0xFF0F766E),
                  ),
                  Text(
                    _monthName(_selectedMonth),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  IconButton(
                    onPressed: isCurrentMonth ? null : _nextMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: isCurrentMonth
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF0F766E),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ الإحصائيات
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'أيام الحضور',
                    value: '${stats['presentDays']}',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF0F766E),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'غير مكتمل',
                    value: '${stats['incompleteDays']}',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'إجمالي التأخير',
                    value: _formatWorkedMinutes(
                        stats['totalLateMinutes']),
                    icon: Icons.timer_off_outlined,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ✅ إجمالي ساعات العمل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF0F766E),
                    Color(0xFF155E75),
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إجمالي ساعات العمل',
                        style: TextStyle(
                          color: Color(0xFFCCFBF1),
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatWorkedMinutes(
                            stats['totalWorkedMinutes']),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ✅ قائمة السجلات
            if (records.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_rounded,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'لا يوجد سجلات لهذا الشهر',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...records.map((record) {
                return _AttendanceRecordCard(
                  record: record,
                  statusColor: _statusColor(record.status),
                  statusText: _statusText(record.status),
                  formatTime: _formatTime,
                  formatWorkedMinutes: _formatWorkedMinutes,
                );
              }),
          ],
        ),
      ),
    );
  }
}

// ✅ بطاقة الإحصائية
class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ بطاقة سجل يوم واحد
class _AttendanceRecordCard extends StatelessWidget {
  const _AttendanceRecordCard({
    required this.record,
    required this.statusColor,
    required this.statusText,
    required this.formatTime,
    required this.formatWorkedMinutes,
  });

  final dynamic record;
  final Color statusColor;
  final String statusText;
  final String Function(String?) formatTime;
  final String Function(int) formatWorkedMinutes;

  String _dayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    const days = [
      'الاثنين', 'الثلاثاء', 'الأربعاء',
      'الخميس', 'الجمعة', 'السبت', 'الأحد',
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ✅ التاريخ
          Container(
            width: 52,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  DateTime.parse(record.attendanceDate)
                      .day
                      .toString(),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: statusColor,
                  ),
                ),
                Text(
                  _dayName(record.attendanceDate),
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 14),

          // ✅ تفاصيل الحضور
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.login_rounded,
                      size: 14,
                      color: Color(0xFF0F766E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatTime(record.checkInAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.logout_rounded,
                      size: 14,
                      color: Color(0xFFF59E0B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatTime(record.checkOutAt),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatWorkedMinutes(record.workedMinutes),
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (record.lateMinutes > 0) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.timer_off_outlined,
                        size: 14,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تأخير ${record.lateMinutes} د',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                if ((record.notes ?? '').toString().trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 14,
                          color: Color(0xFF92400E),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            (record.notes ?? '').toString(),
                            style: const TextStyle(
                              color: Color(0xFF92400E),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ✅ الحالة
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}