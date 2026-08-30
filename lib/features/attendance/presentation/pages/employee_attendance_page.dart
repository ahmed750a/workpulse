import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/attendance_break_model.dart';
import '../../../../core/utils/time_formatters.dart';
import '../providers/attendance_provider.dart';
import '../../../../../core/services/work_timer_service.dart';
class EmployeeAttendancePage extends ConsumerStatefulWidget {
  const EmployeeAttendancePage({super.key});

  @override
  ConsumerState<EmployeeAttendancePage> createState() =>
      _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState extends ConsumerState<EmployeeAttendancePage> {
  String _formatLiveDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(attendanceProvider.notifier).loadTodayRecord();
    });
  }

  String _formatWorkedMinutes(int minutes) {
    if (minutes <= 0) return '0 س';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) return '$mins د';
    if (mins == 0) return '$hours س';

    return '$hours س و $mins د';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final record = state.todayRecord;
    final schedule = state.currentSchedule;
    final isHourlySchedule = schedule?.scheduleType == 'hourly';
    final hasCheckedIn = record?.checkInAt != null;
    final hasCheckedOut = record?.checkOutAt != null;

    final activeBreak = state.activeBreak;
    final totalBreakMinutes = state.totalBreakMinutes;
    final hasActiveBreak = activeBreak != null;

    final lat = state.currentLatitude;
    final lng = state.currentLongitude;
    final distance = state.currentDistanceMeters;
    final isOutside = state.isOutsideGeofence;

    final distanceText = distance == null
        ? '--'
        : distance >= 1000
        ? '${(distance / 1000).toStringAsFixed(2)} كم'
        : '${distance.toStringAsFixed(0)} متر';
    final isDutyOpen = hasCheckedIn && !hasCheckedOut;
    final isGeofenceEnabled = schedule?.geofenceEnabled == true;
    final hasGeofencePoint =
        schedule?.geofenceLat != null && schedule?.geofenceLng != null;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'الحضور والانصراف',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () {
              ref.read(attendanceProvider.notifier).loadTodayRecord();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(attendanceProvider.notifier).loadTodayRecord();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
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
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.fingerprint_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    hasCheckedOut
                        ? 'تم إنهاء دوام اليوم'
                        : hasCheckedIn
                        ? 'أنت داخل الدوام الآن'
                        : 'لم يتم تسجيل حضور اليوم',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سجّل حضورك وانصرافك اليومي من هنا',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFCCFBF1),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SizedBox(height: 22),
            if (isHourlySchedule && schedule != null) ...[
              StreamBuilder<Duration>(
                stream: WorkTimerService.instance.durationStream,
                builder: (context, snapshot) {
                  final liveDuration = snapshot.data ?? Duration.zero;

                  final workedMinutes = hasCheckedIn && !hasCheckedOut
                      ? liveDuration.inMinutes
                      : record?.workedMinutes ?? 0;

                  return _HourlyScheduleOverviewCard(
                    requiredMinutes: schedule.requiredMinutes,
                    workedMinutes: workedMinutes,
                    hasCheckedIn: hasCheckedIn,
                    hasCheckedOut: hasCheckedOut,
                  );
                },
              ),
              const SizedBox(height: 22),
            ],

            if (isDutyOpen) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOutside
                        ? const [Color(0xFFFFF1F2), Color(0xFFFFFBEB)]
                        : const [Color(0xFFECFDF5), Color(0xFFF0F9FF)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isOutside ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                          isOutside ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                          child: Icon(
                            isOutside ? Icons.location_off_rounded : Icons.location_on_rounded,
                            color: isOutside ? const Color(0xFFDC2626) : const Color(0xFF0F766E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'حالة تتبع الموقع',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (lat != null && lng != null)
                          IconButton(
                            tooltip: 'نسخ الإحداثيات',
                            onPressed: () async {
                              final text = '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
                              await Clipboard.setData(ClipboardData(text: text));
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم نسخ الإحداثيات'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 18),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!isGeofenceEnabled)
                      const Text(
                        'النطاق غير مفعل في جدول الدوام.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (!hasGeofencePoint)
                      const Text(
                        'إحداثيات النطاق غير محفوظة في جدول الدوام.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    else if (lat == null || lng == null)
                        const Text(
                          'جاري جلب موقعك الحالي...',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isOutside ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    isOutside ? 'خارج نطاق الدوام' : 'داخل نطاق الدوام',
                                    style: TextStyle(
                                      color: isOutside
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFF0F766E),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  distanceText,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'خط العرض: ${lat.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'خط الطول: ${lng.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

            ],
            if (state.error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: _AttendanceInfoCard(
                    title:
                    isHourlySchedule ? 'بداية الدوام الساعي' : 'وقت الحضور',
                    value: formatDateTimeToTime12(record?.checkInAt),
                    icon: Icons.login_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AttendanceInfoCard(
                    title: isHourlySchedule
                        ? 'نهاية الدوام الساعي'
                        : 'وقت الانصراف',
                    value: formatDateTimeToTime12(record?.checkOutAt),
                    icon: Icons.logout_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            StreamBuilder<Duration>(
              stream: WorkTimerService.instance.durationStream,
              builder: (context, snapshot) {
                final liveDuration = snapshot.data ?? Duration.zero;

                final value = record?.checkInAt != null && record?.checkOutAt == null
                    ? _formatLiveDuration(liveDuration)
                    : _formatWorkedMinutes(record?.workedMinutes ?? 0);

                return _AttendanceInfoCard(
                  title: 'ساعات العمل اليوم',
                  value: value,
                  icon: Icons.access_time_rounded,
                  isWide: true,
                );
              },
            ),
            const SizedBox(height: 26),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: state.isLoading || hasCheckedIn
                    ? null
                    : () async {
                  await ref.read(attendanceProvider.notifier).checkIn();
                },
                icon: state.isLoading && !hasCheckedIn
                    ? const SizedBox(
                  width: 19,
                  height: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.login_rounded),
                label:
                Text(isHourlySchedule ? 'بدء الدوام الساعي' : 'تسجيل حضور'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0F766E),
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  foregroundColor: Colors.white,
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
            const SizedBox(height: 14),
            hasActiveBreak
                ? Tooltip(
              message: isHourlySchedule
                  ? 'أنهِ الراحة أولاً'
                  : 'أنهِ إذن الخروج والعودة أولاً من صفحة الأذونات',
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.logout_rounded),
                  label: Text(isHourlySchedule
                      ? 'إنهاء الدوام الساعي'
                      : 'تسجيل انصراف'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFF59E0B),
                    disabledBackgroundColor: const Color(0xFFCBD5E1),
                    foregroundColor: Colors.white,
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
            )
                : SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: state.isLoading ||
                    !hasCheckedIn ||
                    hasCheckedOut ||
                    hasActiveBreak
                    ? null
                    : () async {
                  await ref
                      .read(attendanceProvider.notifier)
                      .checkOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: Text(isHourlySchedule
                    ? 'إنهاء الدوام الساعي'
                    : 'تسجيل انصراف'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFF59E0B),
                  disabledBackgroundColor: const Color(0xFFCBD5E1),
                  foregroundColor: Colors.white,
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

            if (!isHourlySchedule && hasActiveBreak && hasCheckedIn && !hasCheckedOut) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Text(
                  'لديك إذن خروج وعودة نشط الآن. لإنهائه والعودة للدوام، افتح صفحة "طلبات الأذونات" واضغط "إنهاء الإذن والعودة للدوام".',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF92400E),
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
            if (isHourlySchedule && hasCheckedIn && !hasCheckedOut) ...[
              const SizedBox(height: 14),
              _BreakActionsBar(
                activeBreak: activeBreak,
                hasActiveBreak: hasActiveBreak,
                totalBreakMinutes: totalBreakMinutes,
                isLoading: state.isLoading,
                onStartBreak: () async {
                  await ref.read(attendanceProvider.notifier).startBreak();
                },
                onEndBreak: () async {
                  await ref.read(attendanceProvider.notifier).endBreak();
                },
              ),
            ],
          ],
        ),


      ),
    );
  }
}

class _HourlyScheduleOverviewCard extends StatelessWidget {
  const _HourlyScheduleOverviewCard({
    required this.requiredMinutes,
    required this.workedMinutes,
    required this.hasCheckedIn,
    required this.hasCheckedOut,
  });

  final int requiredMinutes;
  final int workedMinutes;
  final bool hasCheckedIn;
  final bool hasCheckedOut;

  String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0 س';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) return '$mins د';
    if (mins == 0) return '$hours س';

    return '$hours س و $mins د';
  }

  String _statusText() {
    if (!hasCheckedIn) return 'لم يبدأ الدوام بعد';
    if (workedMinutes >= requiredMinutes) {
      return hasCheckedOut ? 'اكتملت ساعات اليوم' : 'تم إكمال المطلوب';
    }
    return 'ساعات قيد الإنجاز';
  }

  Color _statusColor() {
    if (!hasCheckedIn) return const Color(0xFF94A3B8);
    if (workedMinutes >= requiredMinutes) return const Color(0xFF0F766E);
    return const Color(0xFFF59E0B);
  }

  @override
  Widget build(BuildContext context) {
    final remaining = requiredMinutes - workedMinutes;
    final overtime = workedMinutes - requiredMinutes;

    final progress = requiredMinutes <= 0
        ? 0.0
        : (workedMinutes / requiredMinutes).clamp(0.0, 1.0);

    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: Color(0xFF0F766E),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نظام دوام الساعات',
                      style: TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _statusText(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HourlyMetricBox(
                  title: 'المطلوب',
                  value: _formatMinutes(requiredMinutes),
                  icon: Icons.flag_rounded,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HourlyMetricBox(
                  title: 'المنجز',
                  value: _formatMinutes(workedMinutes),
                  icon: Icons.timer_rounded,
                  color: const Color(0xFF0F766E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _HourlyMetricBox(
            title: overtime > 0 ? 'وقت إضافي' : 'المتبقي',
            value: overtime > 0
                ? _formatMinutes(overtime)
                : _formatMinutes(remaining < 0 ? 0 : remaining),
            icon: overtime > 0
                ? Icons.trending_up_rounded
                : Icons.pending_actions_rounded,
            color:
            overtime > 0 ? const Color(0xFF7C3AED) : const Color(0xFFF59E0B),
            isWide: true,
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'في نظام الساعات يتم احتساب الالتزام حسب إجمالي ساعات العمل من الحضور حتى الانصراف النهائي.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF64748B),
                height: 1.5,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HourlyMetricBox extends StatelessWidget {
  const _HourlyMetricBox({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isWide = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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

class _AttendanceInfoCard extends StatelessWidget {
  const _AttendanceInfoCard({
    required this.title,
    required this.value,
    required this.icon,
    this.isWide = false,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWide ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFECFDF5),
            child: Icon(
              icon,
              color: const Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
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

class _BreakActionsBar extends StatelessWidget {
  const _BreakActionsBar({
    required this.activeBreak,
    required this.hasActiveBreak,
    required this.totalBreakMinutes,
    required this.isLoading,
    required this.onStartBreak,
    required this.onEndBreak,
  });

  final AttendanceBreakModel? activeBreak;
  final bool hasActiveBreak;
  final int totalBreakMinutes;
  final bool isLoading;
  final VoidCallback onStartBreak;
  final VoidCallback onEndBreak;

  String _formatBreakMinutes(int minutes) {
    if (minutes <= 0) return '0 د';

    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) return '$mins د';
    if (mins == 0) return '$hours س';
    return '$hours س و $mins د';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: hasActiveBreak
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  hasActiveBreak
                      ? Icons.pause_rounded
                      : Icons.free_breakfast_rounded,
                  color: hasActiveBreak
                      ? const Color(0xFFD97706)
                      : const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasActiveBreak ? 'في راحة الآن' : 'راحة / استراحة',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasActiveBreak
                          ? 'وقت الراحة لا يُحتسب ضمن ساعات العمل'
                          : 'إجمالي الراحة اليوم: ${_formatBreakMinutes(totalBreakMinutes)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed:
              isLoading ? null : (hasActiveBreak ? onEndBreak : onStartBreak),
              icon: isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Icon(
                hasActiveBreak
                    ? Icons.play_arrow_rounded
                    : Icons.pause_rounded,
              ),
              label: Text(
                hasActiveBreak ? 'إنهاء الراحة' : 'بدء الراحة',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: hasActiveBreak
                    ? const Color(0xFFF59E0B)
                    : const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF94A3B8),
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
