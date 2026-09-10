import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../features/attendance/data/models/attendance_record_model.dart';
import '../../features/attendance/data/models/work_schedule_model.dart';

class ShiftReminderService {
  ShiftReminderService._();

  static final ShiftReminderService instance = ShiftReminderService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static const int _checkInReminderId = 3101;
  static const int _checkOutReminderId = 3102;
  static const String _lateReminderShownKey = 'late_shift_reminder_shown';

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _notifications.initialize(settings);

    await _configureLocalTimeZone();
    _initialized = true;
  }

  Future<void> syncTodayReminders({
    required WorkScheduleModel schedule,
    required AttendanceRecordModel? todayRecord,
  }) async {
    await init();

    if (schedule.scheduleType != 'fixed') {
      await _cancelAll();
      return;
    }

    final now = DateTime.now();
    final checkInAt = _dateWithTime(now, schedule.startTime);
    final checkOutAt = _dateWithTime(now, schedule.endTime);

    if (todayRecord?.checkInAt == null) {
      await _scheduleOrShowNow(
        id: _checkInReminderId,
        when: checkInAt,
        title: 'تذكير تسجيل الدخول',
        body: 'حان الآن موعد بداية الدوام. يرجى تسجيل الحضور.',
        lateKey: 'check_in_${_dateKey(now)}',
      );
    } else {
      await _notifications.cancel(_checkInReminderId);
    }

    if (todayRecord?.checkOutAt == null) {
      await _scheduleOrShowNow(
        id: _checkOutReminderId,
        when: checkOutAt,
        title: 'تذكير تسجيل الانصراف',
        body: 'حان الآن موعد نهاية الدوام. يرجى تسجيل الانصراف.',
        lateKey: 'check_out_${_dateKey(now)}',
      );
    } else {
      await _notifications.cancel(_checkOutReminderId);
    }
  }

  Future<void> _scheduleOrShowNow({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    required String lateKey,
  }) async {
    final now = DateTime.now();

    const android = AndroidNotificationDetails(
      'workpulse_shift_reminders',
      'Shift Reminders',
      channelDescription: 'Shift check-in and check-out reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    if (!when.isAfter(now)) {
      await _showLateOnce(
        id: id,
        title: title,
        body: body,
        lateKey: lateKey,
      );
      return;
    }

    final tzWhen = tz.TZDateTime.from(when, tz.local);
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      const NotificationDetails(android: android),
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: 'shift_reminder',
    );
  }

  Future<void> _showLateOnce({
    required int id,
    required String title,
    required String body,
    required String lateKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getStringList(_lateReminderShownKey) ?? <String>[];
    if (shown.contains(lateKey)) return;

    const android = AndroidNotificationDetails(
      'workpulse_shift_reminders',
      'Shift Reminders',
      channelDescription: 'Shift check-in and check-out reminders',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: android),
    );

    shown.add(lateKey);
    if (shown.length > 200) {
      shown.removeRange(0, shown.length - 200);
    }
    await prefs.setStringList(_lateReminderShownKey, shown);
  }

  DateTime _dateWithTime(DateTime date, String hhmmss) {
    final parts = hhmmss.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final second = parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0;

    return DateTime(date.year, date.month, date.day, hour, minute, second);
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  Future<void> _cancelAll() async {
    await _notifications.cancel(_checkInReminderId);
    await _notifications.cancel(_checkOutReminderId);
  }

  Future<void> _configureLocalTimeZone() async {
    tzdata.initializeTimeZones();
    final name = await FlutterTimezone.getLocalTimezone();
    final location = tz.getLocation(name);
    tz.setLocalLocation(location);
  }
}