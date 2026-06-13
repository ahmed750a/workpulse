import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/attendance_provider.dart';
import '../../../../../core/services/work_timer_service.dart';
class EmployeeAttendancePage extends ConsumerStatefulWidget {
  const EmployeeAttendancePage({super.key});

  @override
  ConsumerState<EmployeeAttendancePage> createState() =>
      _EmployeeAttendancePageState();
}

class _EmployeeAttendancePageState
    extends ConsumerState<EmployeeAttendancePage> {



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


  String _formatDateTime(String? value) {
    if (value == null) return '--';

    final date = DateTime.parse(value).toLocal();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
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

    final hasCheckedIn = record?.checkInAt != null;
    final hasCheckedOut = record?.checkOutAt != null;

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
                    title: 'وقت الحضور',
                    value: _formatDateTime(record?.checkInAt),
                    icon: Icons.login_rounded,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _AttendanceInfoCard(
                    title: 'وقت الانصراف',
                    value: _formatDateTime(record?.checkOutAt),
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
                label: const Text('تسجيل حضور'),
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

            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: state.isLoading || !hasCheckedIn || hasCheckedOut
                    ? null
                    : () async {
                  await ref.read(attendanceProvider.notifier).checkOut();
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('تسجيل انصراف'),
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
          ],
        ),
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