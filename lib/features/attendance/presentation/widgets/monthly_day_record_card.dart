import 'package:flutter/material.dart';
import '../../../../core/utils/time_formatters.dart';
import '../../../leaves/data/models/leave_request_model.dart';

class MonthlyDayRecordCardData {
  final DateTime date;
  final dynamic attendance; // AttendanceRecordModel?
  final bool isApprovedLeave;
  final LeaveRequestModel? leave;
  final bool isWeekend;

  const MonthlyDayRecordCardData({
    required this.date,
    required this.attendance,
    required this.isApprovedLeave,
    required this.leave,
    required this.isWeekend,
  });
}

class MonthlyDayRecordCard extends StatelessWidget {
  const MonthlyDayRecordCard({
    super.key,
    required this.item,
    required this.statusText,
    required this.statusColor,
  });

  final MonthlyDayRecordCardData item;
  final String statusText;
  final Color statusColor;

  String _dateKey(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _dayName(DateTime date) {
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

  String _fmtWorkedMinutes(int minutes) {
    if (minutes <= 0) return '0 س';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m د';
    if (m == 0) return '$h س';
    return '$h س و $m د';
  }

  bool _isViolation(dynamic r) {
    final unapprovedLate = (r.unapprovedLateMinutes as int?) ?? 0;
    final unapprovedEarly = (r.unapprovedEarlyLeaveMinutes as int?) ?? 0;
    final notes = (r.notes ?? '').toString().toLowerCase();

    if (unapprovedLate > 0 || unapprovedEarly > 0) return true;
    if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) return true;
    return false;
  }

  List<String> _chips() {
    final r = item.attendance;
    final chips = <String>[];

    if (item.isApprovedLeave) {
      chips.add('إجازة معتمدة');
      if (item.leave?.requestUnit == 'half_day') {
        chips.add(
          item.leave?.halfDayPart == 'first_half'
              ? 'نصف يوم (أول)'
              : 'نصف يوم (ثاني)',
        );
      }
      return chips;
    }

    if (r == null) {
      chips.add(item.isWeekend ? 'عطلة أسبوعية' : 'لا يوجد سجل');
      return chips;
    }

    if ((r.approvedLateMinutes as int? ?? 0) > 0) chips.add('تأخير معتمد');
    if ((r.unapprovedLateMinutes as int? ?? 0) > 0) chips.add('تأخير غير معتمد');
    if ((r.approvedEarlyLeaveMinutes as int? ?? 0) > 0) chips.add('خروج مبكر معتمد');
    if ((r.unapprovedEarlyLeaveMinutes as int? ?? 0) > 0) chips.add('خروج مبكر غير معتمد');

    final notes = (r.notes ?? '').toString().toLowerCase();
    if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) {
      chips.add('تجاوز إذن خروج وعودة');
    }

    if (r.status == 'hours_incomplete') chips.add('ساعات ناقصة');
    if (r.status == 'hours_completed') chips.add('ساعات مكتملة');
    if (r.status == 'hours_completed_with_overtime') chips.add('وقت إضافي');

    if (chips.isEmpty && !_isViolation(r)) chips.add('يوم منتظم');
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    final r = item.attendance;
    final isLeave = item.isApprovedLeave;
    final isEmptyDay = r == null && !isLeave;
    final chips = _chips();

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
                width: 58,
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
                      _dayName(item.date),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
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
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
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
                  formatDateTimeToTime12(r.checkInAt),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.logout_rounded, size: 14, color: Color(0xFFF59E0B)),
                const SizedBox(width: 4),
                Text(
                  formatDateTimeToTime12(r.checkOutAt),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'ساعات العمل: ${_fmtWorkedMinutes((r.workedMinutes as int?) ?? 0)}',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
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
              (r.notes ?? '').toString().trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                (r.notes ?? '').toString(),
                style: const TextStyle(
                  color: Color(0xFF92400E),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
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