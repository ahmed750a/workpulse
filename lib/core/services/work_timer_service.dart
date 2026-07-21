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

  static const String _activeCheckInPrefix = 'active_check_in_time';
  static const String _pendingCheckOutPrefix = 'pending_check_out';

  String _activeCheckInKey(String userId) => '${_activeCheckInPrefix}_$userId';
  String _pendingCheckOutKey(String userId) =>
      '${_pendingCheckOutPrefix}_$userId';

  Future<void> reset() async {
    _timer?.cancel();
    _timer = null;
    _checkInTime = null;
    _durationController.add(Duration.zero);
    await _safeCancel(999);
  }

  // Temporary safe wrappers to prevent plugin crash from breaking app flow.
  Future<void> _safeCancel(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (_) {}
  }

  Future<void> _safeCancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  Future<void> start({
    required String userId,
    required DateTime checkInTime,
  }) async {
    _checkInTime = checkInTime.toLocal();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _activeCheckInKey(userId),
      _checkInTime!.toIso8601String(),
    );

    _timer?.cancel();
    await _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  Future<void> finishLocallyForPendingCheckout({
    required String userId,
  }) async {
    _timer?.cancel();
    _timer = null;
    _checkInTime = null;

    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_activeCheckInKey(userId));
    _durationController.add(Duration.zero);
    await _safeCancel(999);
  }

  Future<void> savePendingCheckOut({required String userId}) async {
    if (_checkInTime == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pendingCheckOutKey(userId),
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<bool> hasPendingCheckOut({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_pendingCheckOutKey(userId));
  }

  Future<DateTime?> getPendingCheckOutTime({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_pendingCheckOutKey(userId));
    if (str == null) return null;
    return DateTime.parse(str).toLocal();
  }

  Future<void> restoreIfActive({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final checkInStr = prefs.getString(_activeCheckInKey(userId));

    if (checkInStr != null) {
      final checkInTime = DateTime.parse(checkInStr).toLocal();
      await start(userId: userId, checkInTime: checkInTime);
    }
  }

  Future<void> stop({required String userId}) async {
    _timer?.cancel();
    _timer = null;
    _checkInTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_activeCheckInKey(userId));
    await prefs.remove(_pendingCheckOutKey(userId));

    _durationController.add(Duration.zero);
    await _safeCancel(999);
  }

  Future<void> _tick() async {
    if (_checkInTime == null) return;
    final duration = DateTime.now().difference(_checkInTime!);
    _durationController.add(duration);

    // Temporarily disabled to avoid local_notifications crash.
     await _showNotification(duration);
  }

  Future<void> _showNotification(Duration duration) async {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');

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

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
    await _safeCancelAll();

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  bool get isRunning => _checkInTime != null;
}