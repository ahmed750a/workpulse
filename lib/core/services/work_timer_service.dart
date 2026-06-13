import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkTimerService {
  WorkTimerService._();

  static final WorkTimerService instance = WorkTimerService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  final StreamController<Duration> _durationController =
  StreamController<Duration>.broadcast();

  Stream<Duration> get durationStream => _durationController.stream;

  Timer? _timer;
  DateTime? _checkInTime;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> start({
    required DateTime checkInTime,
  }) async {
    _checkInTime = checkInTime.toLocal();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'active_check_in_time',
      _checkInTime!.toIso8601String(),
    );

    _timer?.cancel();

    await _tick();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      await _tick();
    });
  }

  Future<void> restoreIfActive() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('active_check_in_time');

    if (value == null) return;

    await start(
      checkInTime: DateTime.parse(value).toLocal(),
    );
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _checkInTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('active_check_in_time');

    _durationController.add(Duration.zero);

    await _notifications.cancel(999);
  }

  Future<void> _tick() async {
    final checkIn = _checkInTime;
    if (checkIn == null) return;

    final duration = DateTime.now().difference(checkIn);

    _durationController.add(duration);

    await _showNotification(duration);
  }

  Future<void> _showNotification(Duration duration) async {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    const androidDetails = AndroidNotificationDetails(
      'workpulse_timer_final',
      'WorkPulse Timer',
      channelDescription: 'WorkPulse active attendance timer',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ongoing: true,
      autoCancel: false,
      onlyAlertOnce: true,
      showWhen: true,
      playSound: false,
      enableVibration: false,
    );

    await _notifications.show(
      999,
      'WorkPulse',
      'أنت داخل الدوام الآن | $hours:$minutes:$seconds',
      const NotificationDetails(android: androidDetails),
    );
  }
}