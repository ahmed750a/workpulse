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

  static const String _activeCheckInKey = 'active_check_in_time';
  static const String _pendingCheckOutKey = 'pending_check_out';

  Future<void> init() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    // ✅ صحيح
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

  }

  Future<void> start({required DateTime checkInTime}) async {
    _checkInTime = checkInTime.toLocal();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _activeCheckInKey, _checkInTime!.toIso8601String());

    _timer?.cancel();
    await _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  // ✅ يحفظ الوقت الفعلي للضغط وليس وقت المزامنة
  Future<void> savePendingCheckOut() async {
    if (_checkInTime == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingCheckOutKey,
      DateTime.now().toUtc().toIso8601String(), // ← وقت الضغط الفعلي
    );
  }

  Future<bool> hasPendingCheckOut() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pendingCheckOutKey);
  }

  // ✅ يرجع الوقت المحفوظ للانصراف المعلق
  Future<DateTime?> getPendingCheckOutTime() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_pendingCheckOutKey);
    if (str == null) return null;
    return DateTime.parse(str).toLocal();
  }

  Future<void> restoreIfActive() async {
    final prefs = await SharedPreferences.getInstance();
    final checkInStr = prefs.getString(_activeCheckInKey);

    if (checkInStr != null) {
      final checkInTime = DateTime.parse(checkInStr).toLocal();
      await start(checkInTime: checkInTime);
    }
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _checkInTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeCheckInKey);
    await prefs.remove(_pendingCheckOutKey);

    _durationController.add(Duration.zero);
    await _notifications.cancel(999);
  }

  Future<void> _tick() async {
    if (_checkInTime == null) return;
    final duration = DateTime.now().difference(_checkInTime!);
    _durationController.add(duration);
    await _showNotification(duration);
  }

  Future<void> _showNotification(Duration duration) async {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, '0');

    const androidDetails = AndroidNotificationDetails(
      'workpulse_timer',
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

  bool get isRunning => _checkInTime != null;
}