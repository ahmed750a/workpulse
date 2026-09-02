import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../leaves/data/models/leave_request_model.dart';
import '../../../leaves/providers/leaves_provider.dart';
import '../providers/attendance_provider.dart';
import '../../../../../core/utils/time_formatters.dart';
import '../widgets/monthly_day_record_card.dart';
class MonthlyAttendancePage extends ConsumerStatefulWidget {
  const MonthlyAttendancePage({super.key});

  @override
  ConsumerState<MonthlyAttendancePage> createState() =>
      _MonthlyAttendancePageState();
}
class _MonthlyDayItem {
  final DateTime date;
  final dynamic attendance; // AttendanceRecordModel?
  final bool isApprovedLeave;
  final LeaveRequestModel? leave;
  final bool isWeekend;

  const _MonthlyDayItem({
    required this.date,
    required this.attendance,
    required this.isApprovedLeave,
    required this.leave,
    required this.isWeekend,
  });

  String get key =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}


DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _dateKey(DateTime d) {
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

Iterable<DateTime> _daysInMonth(DateTime month) sync* {
  final start = DateTime(month.year, month.month, 1);
  final endExclusive = DateTime(month.year, month.month + 1, 1);

  for (var d = start; d.isBefore(endExclusive); d = d.add(const Duration(days: 1))) {
    yield d;
  }
}


List<_MonthlyDayItem> _buildMonthlyDayItems({
  required DateTime month,
  required List<dynamic> attendanceRecords,
  required List<LeaveRequestModel> leaveRequests,
}) {
  final monthDays = _daysInMonth(month).toList();

  final attendanceByDate = <String, dynamic>{};
  for (final r in attendanceRecords) {
    try {
      final d = DateTime.parse(r.attendanceDate);
      attendanceByDate[_dateKey(_dateOnly(d))] = r;
    } catch (_) {}
  }

  final approvedLeaves = leaveRequests.where((l) => l.status == 'approved').toList();



  LeaveRequestModel? findLeaveForDate(DateTime day) {
    for (final leave in approvedLeaves) {
      try {
        final start = _dateOnly(DateTime.parse(leave.startDate));
        final end = _dateOnly(DateTime.parse(leave.endDate));
        final current = _dateOnly(day);
        if (!current.isBefore(start) && !current.isAfter(end)) {
          return leave;
        }
      } catch (_) {}
    }
    return null;
  }

  final result = <_MonthlyDayItem>[];

  for (final day in monthDays) {
    final key = _dateKey(day);
    final attendance = attendanceByDate[key];
    final leave = findLeaveForDate(day);

    final isApprovedLeave = attendance == null && leave != null;
    final isWeekend = day.weekday == DateTime.friday || day.weekday == DateTime.saturday;

    result.add(
      _MonthlyDayItem(
        date: day,
        attendance: attendance,
        isApprovedLeave: isApprovedLeave,
        leave: leave,
        isWeekend: isWeekend,
      ),
    );
  }

  result.sort((a, b) => b.date.compareTo(a.date));
  return result;
}

class _MonthlyAttendancePageState
    extends ConsumerState<MonthlyAttendancePage> {
  DateTime _selectedMonth = DateTime.now();
  String _viewFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(attendanceProvider.notifier)
          .loadMonthlyRecords(_selectedMonth);
      ref.read(leavesProvider.notifier).loadLeavesData();
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
  Map<String, dynamic> _calculateStatsFromDayItems(List<_MonthlyDayItem> items) {
    int presentDays = 0;
    int violationDays = 0;
    int approvedLeaveDays = 0;
    int incompleteDays = 0;

    int totalWorkedMinutes = 0;
    int totalUnapprovedLateMinutes = 0;
    int totalUnapprovedEarlyMinutes = 0;
    int overtimeMinutes = 0;

    bool hasViolation(dynamic r) {
      final unapprovedLate = (r.unapprovedLateMinutes as int?) ?? 0;
      final unapprovedEarly = (r.unapprovedEarlyLeaveMinutes as int?) ?? 0;
      final notes = (r.notes ?? '').toString().toLowerCase();

      if (unapprovedLate > 0 || unapprovedEarly > 0) return true;
      if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) return true;
      return false;
    }

    for (final item in items) {
      final r = item.attendance;

      if (item.isApprovedLeave) {
        approvedLeaveDays++;
        continue;
      }

      if (r == null) continue;

      final hasCheckIn = r.checkInAt != null;
      final hasCheckOut = r.checkOutAt != null;

      if (hasCheckIn && hasCheckOut) {
        presentDays++;
      } else if (hasCheckIn && !hasCheckOut) {
        incompleteDays++;
      }

      totalWorkedMinutes += (r.workedMinutes as int?) ?? 0;
      totalUnapprovedLateMinutes += (r.unapprovedLateMinutes as int?) ?? 0;
      totalUnapprovedEarlyMinutes += (r.unapprovedEarlyLeaveMinutes as int?) ?? 0;

      if (r.status == 'hours_completed_with_overtime') {
        // ما عنا required minutes داخل record الشهري، فنحسبه لاحقًا عند توفره من schedule
        // حاليًا نخليه آمن بدون كسر
      }

      if (hasViolation(r)) {
        violationDays++;
      }
    }

    return {
      'presentDays': presentDays,
      'violationDays': violationDays,
      'approvedLeaveDays': approvedLeaveDays,
      'incompleteDays': incompleteDays,
      'totalWorkedMinutes': totalWorkedMinutes,
      'totalUnapprovedLateMinutes': totalUnapprovedLateMinutes,
      'totalUnapprovedEarlyMinutes': totalUnapprovedEarlyMinutes,
      'overtimeMinutes': overtimeMinutes,
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
  bool _hasViolation(dynamic r) {
    final unapprovedLate = (r.unapprovedLateMinutes as int?) ?? 0;
    final unapprovedEarly = (r.unapprovedEarlyLeaveMinutes as int?) ?? 0;
    final notes = (r.notes ?? '').toString().toLowerCase();

    if (unapprovedLate > 0 || unapprovedEarly > 0) return true;
    if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) return true;
    return false;
  }

  bool _matchesFilter(_MonthlyDayItem item) {
    final r = item.attendance;

    switch (_viewFilter) {
      case 'attendance':
        return r != null;

      case 'violations':
        return r != null && _hasViolation(r);

      case 'leave':
        return item.isApprovedLeave;

      case 'weekend':
        return r == null && !item.isApprovedLeave && item.isWeekend;

      case 'empty':
        return r == null && !item.isApprovedLeave && !item.isWeekend;

      case 'all':
      default:
        return true;
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final leavesState = ref.watch(leavesProvider);

    final records = state.monthlyRecords;
    final myLeaves = leavesState.myRequests;

    final dayItems = _buildMonthlyDayItems(
      month: _selectedMonth,
      attendanceRecords: records,
      leaveRequests: myLeaves,
    );
    final stats = _calculateStatsFromDayItems(dayItems);

    final filteredDayItems = dayItems.where(_matchesFilter).toList();

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left_rounded),
                    color: const Color(0xFF0F766E),
                  ),
                  Expanded(
                    child: Text(
                      _monthName(_selectedMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: isCurrentMonth ? null : _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: isCurrentMonth
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF0F766E),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: isCurrentMonth
                        ? null
                        : () {
                      setState(() {
                        _selectedMonth = DateTime.now();
                      });
                      ref.read(attendanceProvider.notifier).loadMonthlyRecords(_selectedMonth);
                    },
                    icon: const Icon(Icons.today_rounded, size: 16),
                    label: const Text('اليوم'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF99F6E4)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),



            // ✅ إجمالي ساعات العمل
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.15,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _MonthlyKpiCard(
                  title: 'حضور مكتمل',
                  value: '${stats['presentDays']}',
                  icon: Icons.verified_rounded,
                  color: const Color(0xFF0F766E),
                ),
                _MonthlyKpiCard(
                  title: 'أيام مخالفات',
                  value: '${stats['violationDays']}',
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFDC2626),
                ),
                _MonthlyKpiCard(
                  title: 'إجازات معتمدة',
                  value: '${stats['approvedLeaveDays']}',
                  icon: Icons.beach_access_rounded,
                  color: const Color(0xFF7C3AED),
                ),
                _MonthlyKpiCard(
                  title: 'أيام غير مكتملة',
                  value: '${stats['incompleteDays']}',
                  icon: Icons.hourglass_bottom_rounded,
                  color: const Color(0xFFF59E0B),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                    blurRadius: 18,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'الملخص الشهري المتقدم',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MonthlyMiniChip(
                        label: 'إجمالي ساعات العمل',
                        value: _formatWorkedMinutes(stats['totalWorkedMinutes'] as int),
                      ),
                      _MonthlyMiniChip(
                        label: 'تأخير غير معتمد',
                        value: '${stats['totalUnapprovedLateMinutes']} د',
                      ),
                      _MonthlyMiniChip(
                        label: 'خروج مبكر غير معتمد',
                        value: '${stats['totalUnapprovedEarlyMinutes']} د',
                      ),
                      _MonthlyMiniChip(
                        label: 'وقت إضافي',
                        value: '${stats['overtimeMinutes']} د',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(label: 'الكل', selected: _viewFilter == 'all', onTap: () => setState(() => _viewFilter = 'all')),
                  _FilterChip(label: 'حضور', selected: _viewFilter == 'attendance', onTap: () => setState(() => _viewFilter = 'attendance')),
                  _FilterChip(label: 'مخالفات', selected: _viewFilter == 'violations', onTap: () => setState(() => _viewFilter = 'violations')),
                  _FilterChip(label: 'إجازات', selected: _viewFilter == 'leave', onTap: () => setState(() => _viewFilter = 'leave')),
                  _FilterChip(label: 'عطلة أسبوعية', selected: _viewFilter == 'weekend', onTap: () => setState(() => _viewFilter = 'weekend')),
                  _FilterChip(label: 'بدون سجل', selected: _viewFilter == 'empty', onTap: () => setState(() => _viewFilter = 'empty')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ✅ قائمة السجلات
            // ✅ قائمة الأيام الموحدة (حضور + إجازة + أيام بدون حركة)
            if (filteredDayItems.isEmpty)
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
                        'لا يوجد بيانات لهذا الشهر',
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
              ...filteredDayItems.map((item) {
                return MonthlyDayRecordCard(
                  item: MonthlyDayRecordCardData(
                    date: item.date,
                    attendance: item.attendance,
                    isApprovedLeave: item.isApprovedLeave,
                    leave: item.leave,
                    isWeekend: item.isWeekend,
                  ),
                  statusColor: item.isApprovedLeave
                      ? const Color(0xFF7C3AED)
                      : _statusColor(item.attendance?.status),
                  statusText: item.isApprovedLeave
                      ? 'إجازة معتمدة'
                      : _statusText(item.attendance?.status),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF334155),
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFF0F766E),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
    );
  }
}

class _MonthlyKpiCard extends StatelessWidget {
  const _MonthlyKpiCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyMiniChip extends StatelessWidget {
  const _MonthlyMiniChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12,
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
    required this.item,
    required this.statusColor,
    required this.statusText,
    required this.formatTime,
    required this.formatWorkedMinutes,
  });

  final _MonthlyDayItem item;
  final Color statusColor;
  final String statusText;
  final String Function(String?) formatTime;
  final String Function(int) formatWorkedMinutes;
  String _dayName(String dateStr) {
    final date = DateTime.parse(dateStr);
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    return days[date.weekday - 1];
  }

  String _dateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final record = item.attendance;
    final isLeave = item.isApprovedLeave;
    final isEmptyDay = record == null && !isLeave;

    List<String> chips = [];

    if (isLeave) {
      chips.add('إجازة معتمدة');
      if (item.leave?.requestUnit == 'half_day') {
        chips.add(item.leave?.halfDayPart == 'first_half'
            ? 'نصف يوم (أول)'
            : 'نصف يوم (ثاني)');
      }
    } else if (record != null) {
      if ((record.unapprovedLateMinutes as int? ?? 0) > 0) {
        chips.add('تأخير غير معتمد');
      }
      if ((record.approvedLateMinutes as int? ?? 0) > 0) {
        chips.add('تأخير معتمد');
      }
      if ((record.unapprovedEarlyLeaveMinutes as int? ?? 0) > 0) {
        chips.add('خروج مبكر غير معتمد');
      }
      if ((record.approvedEarlyLeaveMinutes as int? ?? 0) > 0) {
        chips.add('خروج مبكر معتمد');
      }

      final notes = (record.notes ?? '').toString().toLowerCase();
      if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) {
        chips.add('تجاوز إذن خروج وعودة');
      }

      if (record.status == 'hours_incomplete') chips.add('ساعات ناقصة');
      if (record.status == 'hours_completed') chips.add('ساعات مكتملة');
      if (record.status == 'hours_completed_with_overtime') chips.add('وقت إضافي');

      if (chips.isEmpty) chips.add('يوم منتظم');
    } else {
      if (item.isWeekend) {
        chips.add('عطلة أسبوعية');
      } else {
        chips.add('لا يوجد سجل');
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      item.date.day.toString(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: statusColor,
                      ),
                    ),
                    Text(
                      _dayName(_dateKey(item.date)),
                      style: TextStyle(
                        fontSize: 10,
                        color: statusColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _dateKey(item.date),
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

          const SizedBox(height: 10),

          if (!isLeave && !isEmptyDay) ...[
            Row(
              children: [
                const Icon(Icons.login_rounded, size: 14, color: Color(0xFF0F766E)),
                const SizedBox(width: 4),
                Text(
                  formatTime(record.checkInAt),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.logout_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  formatTime(record.checkOutAt),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'ساعات العمل: ${formatWorkedMinutes(record.workedMinutes)}',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],

          if (isLeave) ...[
            Text(
              item.leave?.requestUnit == 'half_day'
                  ? 'إجازة نصف يوم معتمدة'
                  : 'إجازة معتمدة لليوم',
              style: const TextStyle(
                color: Color(0xFF5B21B6),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],

          if (isEmptyDay && !item.isWeekend) ...[
            const Text(
              'لا يوجد حضور أو إجازة لهذا اليوم',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],

          if (!isLeave &&
              !isEmptyDay &&
              (record.notes ?? '').toString().trim().isNotEmpty) ...[
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

          const SizedBox(height: 10),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: chips
                .map(
                  (tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Color(0xFF334155),
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                  ),
                ),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }
}