import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_record_model.dart';
import '../../../../core/utils/time_formatters.dart';
import '../providers/attendance_provider.dart';
class AdminEmployeeAttendanceDetailsPage extends ConsumerStatefulWidget {
  const AdminEmployeeAttendanceDetailsPage({
    super.key,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.currentLat,
    required this.currentLng,
    required this.todayStatus,
    required this.isOnDuty,
    this.todayRecord,
  });

  final Map<String, dynamic>? todayRecord;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final double? currentLat;
  final double? currentLng;
  final String? todayStatus;
  final bool isOnDuty;

  @override
  ConsumerState<AdminEmployeeAttendanceDetailsPage> createState() =>
      _AdminEmployeeAttendanceDetailsPageState();
}

class _AdminEmployeeAttendanceDetailsPageState
    extends ConsumerState<AdminEmployeeAttendanceDetailsPage> {
  DateTime _selectedMonth = DateTime.now();
  String _statusFilter = 'all';

  Map<String, dynamic>? _liveTodayPayload;
  bool _isLoadingTodaySnapshot = false;

  Future<void>? _inFlightTodaySnapshot;
  DateTime? _lastTodaySnapshotAt;
  static const Duration _todaySnapshotTtl = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(attendanceProvider.notifier).loadAdminEmployeeMonthlyRecords(
        employeeId: widget.employeeId,
        month: _selectedMonth,
      );

      await _loadTodaySnapshotForEmployee();
    });
  }

  Future<void> _refreshPageData() async {
    await ref.read(attendanceProvider.notifier).loadAdminEmployeeMonthlyRecords(
      employeeId: widget.employeeId,
      month: _selectedMonth,
    );

    await _loadTodaySnapshotForEmployee(force: true);
  }

  Future<void> _loadTodaySnapshotForEmployee({bool force = false}) async {
    // TTL: إذا البيانات لسه حديثة وما طلبنا force، لا نعيد الطلب
    if (!force &&
        _liveTodayPayload != null &&
        _lastTodaySnapshotAt != null &&
        DateTime.now().difference(_lastTodaySnapshotAt!) < _todaySnapshotTtl) {
      return;
    }

    // Single-flight: إذا فيه طلب شغال، استخدم نفس الطلب
    final currentInFlight = _inFlightTodaySnapshot;
    if (currentInFlight != null) {
      return currentInFlight;
    }

    final future = () async {
      if (mounted) {
        setState(() {
          _isLoadingTodaySnapshot = true;
        });
      }

      try {
        final payload = await ref
            .read(attendanceRepositoryProvider)
            .getTodayAttendanceForEmployeeForAdmin(
          employeeId: widget.employeeId,
        );

        if (!mounted) return;

        setState(() {
          _liveTodayPayload = payload;
          _lastTodaySnapshotAt = DateTime.now();
        });
      } catch (_) {
        // fallback: keep current/passed data
      } finally {
        _inFlightTodaySnapshot = null;
        if (mounted) {
          setState(() {
            _isLoadingTodaySnapshot = false;
          });
        }
      }
    }();

    _inFlightTodaySnapshot = future;
    return future;
  }
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });

    ref.read(attendanceProvider.notifier).loadAdminEmployeeMonthlyRecords(
      employeeId: widget.employeeId,
      month: _selectedMonth,
    );
  }

  void _nextMonth() {
    final now = DateTime.now();
    if (_selectedMonth.year == now.year && _selectedMonth.month == now.month) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });

    ref.read(attendanceProvider.notifier).loadAdminEmployeeMonthlyRecords(
      employeeId: widget.employeeId,
      month: _selectedMonth,
    );
  }

  String _monthName(DateTime date) {
    const months = [
      'يناير', 'فبراير', 'مارس', 'إبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _statusText(String? status) {
    switch (status) {
      case 'checked_in':
        return 'داخل الدوام';
      case 'checked_out':
        return 'مكتمل';
      case 'late':
        return 'تأخير غير معتمد';
      case 'approved_late':
        return 'تأخير معتمد';
      case 'partially_approved_late':
        return 'تأخير جزئي';
      case 'early_leave':
        return 'خروج مبكر غير معتمد';
      case 'early_leave_partial':
        return 'خروج مبكر جزئي';
      case 'early_leave_approved':
        return 'خروج مبكر معتمد';
      case 'late_checked_out':
        return 'مكتمل مع تأخير';
      case 'hours_incomplete':
        return 'ساعات ناقصة';
      case 'hours_completed':
        return 'ساعات مكتملة';
      case 'hours_completed_with_overtime':
        return 'ساعات مكتملة مع إضافي';
      default:
        return status == null || status.trim().isEmpty ? '--' : status;
    }
  }
  List<String> _deriveStatusTags(AttendanceRecordModel record) {
    final tags = <String>[];

    if (record.unapprovedLateMinutes > 0) tags.add('تأخير غير معتمد');
    if (record.approvedLateMinutes > 0) tags.add('تأخير معتمد');

    if (record.unapprovedEarlyLeaveMinutes > 0) {
      tags.add('خروج مبكر غير معتمد');
    }
    if (record.approvedEarlyLeaveMinutes > 0) {
      tags.add('خروج مبكر معتمد');
    }

    if (record.status == 'hours_incomplete') tags.add('ساعات ناقصة');
    if (record.status == 'hours_completed') tags.add('ساعات مكتملة');
    if (record.status == 'hours_completed_with_overtime') tags.add('وقت إضافي');

    final notes = (record.notes ?? '').toLowerCase();
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

    final liveRecord = _liveTodayPayload?['record'] as Map<String, dynamic>?;

    final passedRecord =
    (widget.todayRecord != null && widget.todayRecord!.isNotEmpty)
        ? widget.todayRecord
        : null;

    final effectiveRecord = liveRecord ?? passedRecord;

    final hasTodayRecord = effectiveRecord != null && effectiveRecord.isNotEmpty;

    final effectiveStatus =
        _liveTodayPayload?['todayStatus']?.toString() ?? widget.todayStatus;

    final effectiveIsOnDuty =
        (_liveTodayPayload?['isOnDuty'] as bool?) ?? widget.isOnDuty;

    final effectiveLat = _liveTodayPayload?['currentLat'] is num
        ? (_liveTodayPayload?['currentLat'] as num).toDouble()
        : widget.currentLat;

    final effectiveLng = _liveTodayPayload?['currentLng'] is num
        ? (_liveTodayPayload?['currentLng'] as num).toDouble()
        : widget.currentLng;

    final effectiveEmployeeName =
    (_liveTodayPayload?['employeeName']?.toString().trim().isNotEmpty ?? false)
        ? _liveTodayPayload!['employeeName'].toString()
        : widget.employeeName;

    final effectiveEmployeeEmail =
    (_liveTodayPayload?['employeeEmail']?.toString().trim().isNotEmpty ?? false)
        ? _liveTodayPayload!['employeeEmail'].toString()
        : widget.employeeEmail;

    final records = state.adminEmployeeRecords.where((r) {
      if (_statusFilter == 'all') return true;
      final tags = _deriveStatusTags(r);
      return tags.contains(_statusFilter);
    }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('تفاصيل حضور الموظف'),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: (state.isLoading || _isLoadingTodaySnapshot)
                ? null
                : () async {
              await _refreshPageData();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0x33FFFFFF),
                      child: Icon(Icons.person_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            effectiveEmployeeName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            effectiveEmployeeEmail,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                              color: Color(0xFFCCFBF1),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (_isLoadingTodaySnapshot) ...[
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                        ],
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _statusText(effectiveStatus),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: hasTodayRecord
                      ? _deriveStatusTags(AttendanceRecordModel.fromJson(effectiveRecord!))
                      .map((t) => _StatusTagChip(label: t))
                      .toList()
                      : const [ _StatusTagChip(label: 'لا يوجد سجل حضور اليوم') ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                      'حضور: ${formatDateTimeToTime12(effectiveRecord?['check_in_at']?.toString())}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    Expanded(
                      child: Text(
    'انصراف: ${formatDateTimeToTime12(effectiveRecord?['check_out_at']?.toString())}',

    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
    'ساعات العمل: ${(effectiveRecord?['worked_minutes'] ?? 0)} دقيقة',
                  style: const TextStyle(color: Color(0xFFE0F2FE), fontWeight: FontWeight.w700),
                ),
                if (effectiveIsOnDuty && effectiveLat != null && effectiveLng != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
    'الموقع الحالي: ${effectiveLat!.toStringAsFixed(6)}, ${effectiveLng!.toStringAsFixed(6)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          final text = '${effectiveLat!.toStringAsFixed(6)},${effectiveLng!.toStringAsFixed(6)}';

                          await Clipboard.setData(ClipboardData(text: text));
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم نسخ الإحداثيات')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child:Row(
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
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right_rounded),
                    color: const Color(0xFF0F766E),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _statusFilter,
                    decoration: const InputDecoration(
                      labelText: 'فلترة الحالة',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('الكل')),
                      DropdownMenuItem(value: 'تأخير غير معتمد', child: Text('تأخير غير معتمد')),
                      DropdownMenuItem(value: 'تأخير معتمد', child: Text('تأخير معتمد')),
                      DropdownMenuItem(value: 'خروج مبكر غير معتمد', child: Text('خروج مبكر غير معتمد')),
                      DropdownMenuItem(value: 'خروج مبكر معتمد', child: Text('خروج مبكر معتمد')),
                      DropdownMenuItem(value: 'ساعات ناقصة', child: Text('ساعات ناقصة')),
                      DropdownMenuItem(value: 'ساعات مكتملة', child: Text('ساعات مكتملة')),
                      DropdownMenuItem(value: 'وقت إضافي', child: Text('وقت إضافي')),
                      DropdownMenuItem(value: 'تجاوز إذن خروج وعودة', child: Text('تجاوز إذن خروج وعودة')),
                      DropdownMenuItem(value: 'لا توجد مخالفات', child: Text('لا توجد مخالفات')),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _statusFilter = v);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: records.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final r = records[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('التاريخ: ${r.attendanceDate}',
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        'الحضور: ${formatDateTimeToTime12(r.checkInAt)} - الانصراف: ${formatDateTimeToTime12(r.checkOutAt)}',
                      ),
                      Text('الحالة: ${_statusText(r.status)}'),
                      Text('ساعات العمل: ${r.workedMinutes} دقيقة'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _deriveStatusTags(r)
                            .map((tag) => _StatusTagChip(label: tag))
                            .toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
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