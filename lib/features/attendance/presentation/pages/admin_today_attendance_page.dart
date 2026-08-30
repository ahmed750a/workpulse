import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'admin_employee_attendance_details_page.dart';
import '../../../../core/utils/time_formatters.dart';
import '../providers/attendance_provider.dart';
import 'admin_employee_attendance_details_page.dart';
class AdminTodayAttendancePage extends ConsumerStatefulWidget {
  const AdminTodayAttendancePage({super.key});

  @override
  ConsumerState<AdminTodayAttendancePage> createState() =>
      _AdminTodayAttendancePageState();
}

class _AdminTodayAttendancePageState
    extends ConsumerState<AdminTodayAttendancePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(attendanceProvider.notifier).loadTodayAttendanceForAdmin();
    });
  }

  String _statusText(String? status) {
    switch (status) {
      case 'checked_in':
        return 'داخل الدوام';
      case 'checked_out':
        return 'مكتمل';
      case 'late':
        return 'متأخر';
      case 'approved_late':
        return 'تأخير معتمد';
      case 'partially_approved_late':
        return 'تأخير جزئي';
      case 'early_leave':
        return 'خروج مبكر';
      case 'late_checked_out':
        return 'مكتمل مع تأخير';
      case 'hours_incomplete':
        return 'ساعات ناقصة';
      case 'hours_completed':
        return 'ساعات مكتملة';
      case 'hours_completed_with_overtime':
        return 'أوفر تايم';
      default:
        return status ?? '--';
    }
  }

  Color _statusColor(String? status) {
    switch (status) {
      case 'checked_in':
        return const Color(0xFF0284C7);
      case 'checked_out':
      case 'approved_late':
      case 'hours_completed':
        return const Color(0xFF0F766E);
      case 'late':
      case 'early_leave':
        return const Color(0xFFDC2626);
      case 'partially_approved_late':
      case 'late_checked_out':
      case 'hours_incomplete':
        return const Color(0xFFF59E0B);
      case 'hours_completed_with_overtime':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF64748B);
    }
  }
  List<String> _deriveStatusTags(Map<String, dynamic> record) {
    int toInt(dynamic value) {
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '0') ?? 0;
    }

    final tags = <String>[];

    final approvedLate = toInt(record['approved_late_minutes']);
    final unapprovedLate = toInt(record['unapproved_late_minutes']);
    final approvedEarly = toInt(record['approved_early_leave_minutes']);
    final unapprovedEarly = toInt(record['unapproved_early_leave_minutes']);
    final status = record['status']?.toString() ?? '';
    final notes = (record['notes']?.toString() ?? '').toLowerCase();

    if (unapprovedLate > 0) tags.add('تأخير غير معتمد');
    if (approvedLate > 0) tags.add('تأخير معتمد');
    if (unapprovedEarly > 0) tags.add('خروج مبكر غير معتمد');
    if (approvedEarly > 0) tags.add('خروج مبكر معتمد');

    if (status == 'hours_incomplete') tags.add('ساعات ناقصة');
    if (status == 'hours_completed') tags.add('ساعات مكتملة');
    if (status == 'hours_completed_with_overtime') tags.add('وقت إضافي');

    if (notes.contains('تجاوز') || notes.contains('خروج/عودة')) {
      tags.add('تجاوز إذن خروج وعودة');
    }

    if (tags.isEmpty) {
      tags.add('لا توجد مخالفات');
    }

    return tags;
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final rows = state.todayAdminAttendance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'الحضور اليومي',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () {
              ref
                  .read(attendanceProvider.notifier)
                  .loadTodayAttendanceForAdmin();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          if (rows.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد سجلات حضور لهذا اليوم',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(attendanceProvider.notifier)
                  .loadTodayAttendanceForAdmin();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = rows[index];
                final record = row['record'] as Map<String, dynamic>? ?? {};
                final status = record['status']?.toString();
                final color = _statusColor(status);
                final tags = _deriveStatusTags(record);
                final name = row['employeeName']?.toString() ?? 'غير معروف';
                final email = row['employeeEmail']?.toString() ?? '';
                final checkInAt = record['check_in_at']?.toString();
                final checkOutAt = record['check_out_at']?.toString();

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final checkOutAt = record['check_out_at']?.toString();

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AdminEmployeeAttendanceDetailsPage(
                          employeeId: row['employeeId']?.toString() ?? '',
                          employeeName: row['employeeName']?.toString() ?? 'غير معروف',
                          employeeEmail: row['employeeEmail']?.toString() ?? '',
                          currentLat: row['currentLat'] is num
                              ? (row['currentLat'] as num).toDouble()
                              : null,
                          currentLng: row['currentLng'] is num
                              ? (row['currentLng'] as num).toDouble()
                              : null,
                          todayStatus: status,
                          isOnDuty: checkOutAt == null,
                          todayRecord: record, // جديد
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _statusText(status),
                                style: TextStyle(
                                  color: color,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.login_rounded,
                              size: 15,
                              color: Color(0xFF0F766E),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTimeToTime12(checkInAt),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 14),
                            const Icon(
                              Icons.logout_rounded,
                              size: 15,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatDateTimeToTime12(checkOutAt),
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags.map((tag) => _StatusTagChip(label: tag)).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
class _StatusTagChip extends StatelessWidget {
  const _StatusTagChip({required this.label});

  final String label;

  Color _textColor() {
    if (label.contains('غير معتمد') || label.contains('تجاوز')) {
      return const Color(0xFFB91C1C);
    }

    if (label.contains('معتمد')) {
      return const Color(0xFF065F46);
    }

    if (label.contains('ناقصة')) {
      return const Color(0xFF92400E);
    }

    if (label.contains('إضافي')) {
      return const Color(0xFF5B21B6);
    }

    return const Color(0xFF334155);
  }

  Color _bgColor() {
    if (label.contains('غير معتمد') || label.contains('تجاوز')) {
      return const Color(0xFFFEF2F2);
    }

    if (label.contains('معتمد')) {
      return const Color(0xFFECFDF5);
    }

    if (label.contains('ناقصة')) {
      return const Color(0xFFFFFBEB);
    }

    if (label.contains('إضافي')) {
      return const Color(0xFFF5F3FF);
    }

    return const Color(0xFFF8FAFC);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bgColor(),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _bgColor()),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _textColor(),
          fontWeight: FontWeight.w800,
          fontSize: 11,
        ),
      ),
    );
  }
}