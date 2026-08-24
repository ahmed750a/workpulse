import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/permission_model.dart';
import '../providers/permissions_provider.dart';
import '../../../../../core/utils/time_formatters.dart';
import '../../../attendance/data/models/work_schedule_model.dart';
import '../../../attendance/presentation/providers/attendance_provider.dart';
import '../../../attendance/data/models/attendance_record_model.dart';
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(permissionsProvider.notifier).loadMyPermissions();
      ref.read(attendanceProvider.notifier).loadTodayRecord(); // ✅ لتحميل جدول الدوام الحالي
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ نوع الإذن بالعربي
  String _typeText(String type) {
    switch (type) {
      case 'late_arrival':
        return 'تأخير دخول';
      case 'early_leave':
        return 'خروج مبكر';
      case 'exit_return':
        return 'خروج وعودة';
      default:
        return type;
    }
  }

  // ✅ لون الحالة
  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF0F766E);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  // ✅ نص الحالة
  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionsProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final WorkScheduleModel? currentSchedule = attendanceState.currentSchedule;
    final AttendanceRecordModel? todayRecord = attendanceState.todayRecord;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'طلبات الأذونات',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFCCFBF1),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'طلباتي'),
            Tab(text: 'طلب جديد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ تاب طلباتي
          _MyPermissionsTab(
            isLoading: state.isLoading,
            error: state.error,
            permissions: state.permissions,
            onRefresh: () async {
              await ref.read(permissionsProvider.notifier).loadMyPermissions();
              await ref.read(attendanceProvider.notifier).loadTodayRecord();
            },
            onCancel: (id) async {
              final confirm = await _showCancelDialog(context);
              if (confirm != true) return;
              await ref.read(permissionsProvider.notifier).cancelPermission(id);
            },
            typeText: _typeText,
            statusColor: _statusColor,
            statusText: _statusText,
            hasCheckedIn: todayRecord?.checkInAt != null,
            hasCheckedOut: todayRecord?.checkOutAt != null,
            isExitReturnUsageActive:
            attendanceState.activeBreak != null &&
                currentSchedule?.scheduleType == 'fixed',
            isActionLoading: attendanceState.isLoading,
            onStartExitReturn: () async {
              await ref.read(attendanceProvider.notifier).startExitReturnPermission();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم بدء استخدام إذن الخروج والعودة'),
                  backgroundColor: Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            onEndExitReturn: () async {
              await ref.read(attendanceProvider.notifier).endExitReturnPermission();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم إنهاء الإذن والعودة للدوام'),
                  backgroundColor: Color(0xFF0F766E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),

          // ✅ تاب طلب جديد
          _NewPermissionTab(
            isSubmitting: state.isSubmitting,
            error: state.error,
            onSubmit: ({
              required String date,
              required String startTime,
              required String endTime,
              required String type,
              required String reason,
            }) async {
              final success = await ref
                  .read(permissionsProvider.notifier)
                  .createPermission(
                permissionDate: date,
                startTime: startTime,
                endTime: endTime,
                type: type,
                reason: reason,
              );

              if (success && context.mounted) {
                _tabController.animateTo(0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال طلب الإذن بنجاح'),
                    backgroundColor: Color(0xFF0F766E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            typeText: _typeText,
            currentSchedule: currentSchedule, // ✅ الآن صار له تعريف في constructor
            todayRecord: todayRecord,
          ),
        ],
      ),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'إلغاء الطلب',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('هل تريد إلغاء هذا الطلب نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}

// ✅ تاب طلباتي
class _MyPermissionsTab extends StatelessWidget {
  const _MyPermissionsTab({
    required this.isLoading,
    required this.error,
    required this.permissions,
    required this.onRefresh,
    required this.onCancel,
    required this.typeText,
    required this.statusColor,
    required this.statusText,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
    required this.isExitReturnUsageActive,
    required this.isActionLoading,
    required this.onStartExitReturn,
    required this.onEndExitReturn,
  });

  final bool isLoading;
  final String? error;
  final List<PermissionModel> permissions;
  final Future<void> Function() onRefresh;
  final Function(String) onCancel;
  final String Function(String) typeText;
  final Color Function(String) statusColor;
  final String Function(String) statusText;
  final bool hasCheckedIn;
  final bool hasCheckedOut;
  final bool isExitReturnUsageActive;
  final bool isActionLoading;
  final Future<void> Function() onStartExitReturn;
  final Future<void> Function() onEndExitReturn;


  String _todayDate() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  DateTime? _toDateTime(String date, String time) {
    try {
      final d = DateTime.parse(date);
      final parts = time.split(':');
      return DateTime(
        d.year,
        d.month,
        d.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isExitReturnApprovedToday(PermissionModel p) {
    return p.type == 'exit_return' &&
        p.status == 'approved' &&
        p.permissionDate == _todayDate();
  }

  bool _isNowWithinWindow(PermissionModel p) {
    final now = DateTime.now();
    final start = _toDateTime(p.permissionDate, p.startTime);
    final end = _toDateTime(p.permissionDate, p.endTime);
    if (start == null || end == null) return false;
    return !now.isBefore(start) && !now.isAfter(end);
  }

  String _windowHint(PermissionModel p) {
    final now = DateTime.now();
    final start = _toDateTime(p.permissionDate, p.startTime);
    final end = _toDateTime(p.permissionDate, p.endTime);
    if (start == null || end == null) return 'تعذر قراءة فترة الإذن.';
    if (now.isBefore(start)) {
      return 'لم يبدأ موعد الإذن بعد. يبدأ عند ${formatTime12(p.startTime)}';
    }
    if (now.isAfter(end)) {
      return 'انتهت نافذة الإذن لهذا اليوم.';
    }
    return '';
  }
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (permissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد طلبات أذونات سابقة',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: permissions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final permission = permissions[index];
          final color = statusColor(permission.status);

          return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // نوع الإذن
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        typeText(permission.type),
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // الحالة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText(permission.status),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // التاريخ والوقت
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      permission.permissionDate,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${formatTime12(permission.startTime)} - ${formatTime12(permission.endTime)}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // السبب
                Text(
                  permission.reason,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                // زر الإلغاء للطلبات المعلقة فقط
                if (permission.status == 'pending') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => onCancel(permission.id),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'إلغاء الطلب',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                // سبب الرفض
                // سبب الرفض
                if (permission.status == 'rejected' &&
                    permission.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'سبب الرفض: ${permission.rejectionReason}',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // تشغيل إذن خروج/عودة المعتمد لليوم
                if (_isExitReturnApprovedToday(permission)) ...[
                  const SizedBox(height: 12),
                  if (hasCheckedOut)
                    const Text(
                      'تم إنهاء الدوام اليوم، لا يمكن تشغيل الإذن.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (!hasCheckedIn)
                    const Text(
                      'يجب تسجيل الحضور أولا قبل استخدام إذن الخروج والعودة.',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else if (isExitReturnUsageActive)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: isActionLoading ? null : () => onEndExitReturn(),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('إنهاء الإذن والعودة للدوام'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFF59E0B),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      )
                    else if (_isNowWithinWindow(permission))
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isActionLoading ? null : () => onStartExitReturn(),
                            icon: const Icon(Icons.pause_rounded),
                            label: const Text('بدء استخدام إذن الخروج والعودة'),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        )
                      else
                        Text(
                          _windowHint(permission),
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ✅ تاب طلب جديد
class _NewPermissionTab extends StatefulWidget {
  const _NewPermissionTab({
    super.key,
    required this.isSubmitting,
    required this.error,
    required this.onSubmit,
    required this.typeText,
    this.currentSchedule,
    this.todayRecord,// ✅ بارامتر اختياري
  });

  final bool isSubmitting;
  final String? error;

  final Future<void> Function({
  required String date,
  required String startTime,
  required String endTime,
  required String type,
  required String reason,
  }) onSubmit;

  final String Function(String) typeText;

  // ✅ الحقل الجديد
  final WorkScheduleModel? currentSchedule;
  final AttendanceRecordModel? todayRecord;
  @override
  State<_NewPermissionTab> createState() => _NewPermissionTabState();
}

class _NewPermissionTabState extends State<_NewPermissionTab> {
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _selectedType = 'early_leave';
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
  DateTime _combine(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  DateTime? _parseScheduleTime(String? timeStr) {
    if (timeStr == null) return null;
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );
  }

  Future<void> _showValidationDialog(String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'لا يمكن إرسال الطلب',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: Text(
            message,
            style: const TextStyle(
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('حسناً'),
            ),
          ],
        );
      },
    );
  }
  Future<bool> _validateRequest() async {
    final schedule = widget.currentSchedule;
    if (schedule == null) {
      await _showValidationDialog('لا يوجد جدول دوام مرتبط بك حاليا.');
      return false;
    }

    if (schedule.scheduleType != 'fixed') {
      await _showValidationDialog(
        'طلبات التأخير/الخروج مرتبطة بالدوام الثابت فقط حاليا.',
      );
      return false;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reqDate =
    DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    final isToday = _isSameDay(reqDate, today);

// فقط الماضي ممنوع
    if (reqDate.isBefore(today)) {
      await _showValidationDialog('لا يمكن تقديم طلب على تاريخ ماض.');
      return false;
    }

    // يوم ليس يوم دوام
    if (!schedule.workDays.contains(reqDate.weekday)) {
      await _showValidationDialog('التاريخ المحدد ليس من أيام دوامك الرسمية.');
      return false;
    }

    final scheduleStart = _parseScheduleTime(schedule.startTime);
    final scheduleEnd = _parseScheduleTime(schedule.endTime);

    if (scheduleStart == null || scheduleEnd == null) {
      await _showValidationDialog('تعذر قراءة وقت الدوام من الجدول.');
      return false;
    }

    final start = _combine(_selectedDate, _selectedTime);
    final end = _combine(_selectedDate, _endTime);

    final hasCheckedIn = widget.todayRecord?.checkInAt != null;
    final hasCheckedOut = widget.todayRecord?.checkOutAt != null;
    final isInsideWorkNow = hasCheckedIn && !hasCheckedOut;

    final reason = _reasonController.text.trim();
    if (reason.length < 5) {
      await _showValidationDialog('يرجى كتابة سبب واضح (5 أحرف على الأقل).');
      return false;
    }

    if (_selectedType == 'late_arrival') {
      // اليوم الحالي: لا تأخير بعد الحضور
      if (isToday && hasCheckedIn) {
        await _showValidationDialog('لا يمكن طلب إذن تأخير بعد تسجيل الحضور.');
        return false;
      }

      // ضمن الدوام
      if (start.isBefore(scheduleStart) || start.isAfter(scheduleEnd)) {
        await _showValidationDialog('وقت التأخير يجب أن يكون ضمن وقت الدوام الرسمي.');
        return false;
      }

      // اليوم الحالي: وقت منتهي
      if (isToday && !start.isAfter(now)) {
        await _showValidationDialog('وقت إذن التأخير انتهى بالفعل.');
        return false;
      }
    }

    if (_selectedType == 'early_leave') {
      // اليوم الحالي: فقط أثناء الدوام
      if (isToday && !isInsideWorkNow) {
        await _showValidationDialog(
          'لا يمكن طلب خروج مبكر لليوم الحالي إلا أثناء وجودك داخل الدوام.',
        );
        return false;
      }

      // ضمن الدوام وقبل النهاية
      if (!start.isAfter(scheduleStart) || !start.isBefore(scheduleEnd)) {
        await _showValidationDialog(
          'وقت الخروج المبكر يجب أن يكون بعد بداية الدوام وقبل نهايته.',
        );
        return false;
      }

      // اليوم الحالي: وقت مضى
      if (isToday && !start.isAfter(now)) {
        await _showValidationDialog('لا يمكن طلب خروج مبكر لوقت مضى.');
        return false;
      }
    }

    if (_selectedType == 'exit_return') {
      // اليوم الحالي: فقط أثناء الدوام
      if (isToday && !isInsideWorkNow) {
        await _showValidationDialog(
          'لا يمكن طلب خروج وعودة لليوم الحالي إلا أثناء وجودك داخل الدوام.',
        );
        return false;
      }

      // العودة بعد الخروج
      if (!end.isAfter(start)) {
        await _showValidationDialog('وقت العودة يجب أن يكون بعد وقت الخروج.');
        return false;
      }

      // ضمن الدوام
      if (start.isBefore(scheduleStart) || end.isAfter(scheduleEnd)) {
        await _showValidationDialog(
          'فترة الخروج والعودة يجب أن تكون ضمن وقت الدوام الرسمي.',
        );
        return false;
      }

      // اليوم الحالي: لا تبدأ بفترة ماضية
      if (isToday && !start.isAfter(now)) {
        await _showValidationDialog('وقت الخروج يجب أن يكون لاحقا للوقت الحالي.');
        return false;
      }
    }

    return true;
  }
  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: today,
      lastDate: DateTime(today.year + 10, 12, 31), // أي يوم مستقبلي (حتى 10 سنوات)
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) setState(() => _endTime = picked);
  }

  // ✅ عنوان حقل الوقت حسب النوع
  String get _timeLabel {
    switch (_selectedType) {
      case 'late_arrival':
        return 'وقت الوصول المتوقع';
      case 'early_leave':
        return 'وقت الخروج';
      case 'exit_return':
        return 'وقت الخروج';
      default:
        return 'الوقت';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ نوع الإذن
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نوع الإذن',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                ...['late_arrival', 'early_leave', 'exit_return']
                    .map((type) => RadioListTile<String>(
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (v) =>
                      setState(() => _selectedType = v!),
                  title: Text(
                    widget.typeText(type),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  activeColor: const Color(0xFF0F766E),
                  contentPadding: EdgeInsets.zero,
                )),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ التاريخ
          _PickerTile(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: _formatDate(_selectedDate),
            onTap: _pickDate,
          ),

          const SizedBox(height: 10),

          // ✅ الوقت - حسب النوع
          _PickerTile(
            icon: Icons.access_time_rounded,
            label: _timeLabel,
            value: formatTimeOfDay12(_selectedTime),
            onTap: _pickTime,
          ),

          // ✅ وقت العودة فقط لـ exit_return
          if (_selectedType == 'exit_return') ...[
            const SizedBox(height: 10),
            _PickerTile(
              icon: Icons.access_time_filled_rounded,
              label: 'وقت العودة',
              value: formatTimeOfDay12(_endTime),
              onTap: _pickEndTime,
            ),
          ],

          const SizedBox(height: 14),

          // ✅ السبب
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب سبب الإذن...',
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ✅ رسالة الخطأ
          if (widget.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.error!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // ✅ زر الإرسال
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: widget.isSubmitting
                  ? null
                  : () async {
                if (_reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى كتابة سبب الإذن'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                  return;
                }

                // ✅ تحقق من منطق الوقت والحالة قبل الإرسال
                final isValid = await _validateRequest();
                if (!isValid) return;

                // بعد ما نتأكد أن الطلب منطقي نكمّل حساب start/end
                final selected = _formatTimeOfDay(_selectedTime);
                final selectedEnd = _formatTimeOfDay(_endTime);

                final scheduleStart = widget.currentSchedule?.startTime;
                final scheduleEnd = widget.currentSchedule?.endTime;

                late String startTime;
                late String endTime;

                switch (_selectedType) {
                  case 'late_arrival':
                    startTime = scheduleStart ?? selected;
                    endTime = selected;
                    break;
                  case 'early_leave':
                    startTime = selected;
                    endTime = scheduleEnd ?? selected;
                    break;
                  case 'exit_return':
                    startTime = selected;
                    endTime = selectedEnd;
                    break;
                  default:
                    startTime = selected;
                    endTime = selected;
                }

                await widget.onSubmit(
                  date: _formatDate(_selectedDate),
                  startTime: startTime,
                  endTime: endTime,
                  type: _selectedType,
                  reason: _reasonController.text.trim(),
                );
              },
              icon: widget.isSubmitting
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.send_rounded),
              label: const Text('إرسال الطلب'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget مساعد لاختيار التاريخ والوقت
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F766E), size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}