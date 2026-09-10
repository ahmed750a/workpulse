import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationListenerService {
  NotificationListenerService._();
  static final NotificationListenerService instance =
  NotificationListenerService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  RealtimeChannel? _channel;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  String? _userId;
  static const String _shownIdsKey = 'shown_app_notification_ids';

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> startForUser(String userId) async {
    if (_userId == userId && _channel != null) return;

    await stop();
    _userId = userId;

    await _showMissed(userId);
    _subscribe(userId);
    _startConnectivitySync();
  }

  Future<void> stop() async {
    await _connectivitySub?.cancel();
    _connectivitySub = null;

    if (_channel != null) {
      await Supabase.instance.client.removeChannel(_channel!);
      _channel = null;
    }

    _userId = null;
  }

  void _subscribe(String userId) {
    final client = Supabase.instance.client;

    _channel = client.channel('app_notifications_$userId')
      ..onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'app_notifications',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'recipient_id',
          value: userId,
        ),
        callback: (payload) async {
          final row = payload.newRecord;
          if (row.isEmpty) return;
          await _showLocal(Map<String, dynamic>.from(row));
        },
      )
      ..subscribe();
  }

  void _startConnectivitySync() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      if (_userId == null) return;
      if (results.isEmpty) return;
      if (results.first == ConnectivityResult.none) return;
      _showMissed(_userId!);
    });
  }

  Future<void> _showMissed(String userId) async {
    final rows = await Supabase.instance.client
        .from('app_notifications')
        .select()
        .eq('recipient_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: true)
        .limit(50);

    for (final item in rows) {
      await _showLocal(Map<String, dynamic>.from(item));
    }
  }

  Future<void> _showLocal(Map<String, dynamic> row) async {
    final id = row['id']?.toString();
    if (id == null) return;

    if (await _alreadyShown(id)) return;

    const androidDetails = AndroidNotificationDetails(
      'workpulse_app_notifications',
      'WorkPulse Notifications',
      channelDescription: 'General app notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _notifications.show(
      id.hashCode & 0x7fffffff,
      row['title']?.toString() ?? 'إشعار جديد',
      row['body']?.toString() ?? '',
      const NotificationDetails(android: androidDetails),
    );

    await _markShown(id);
  }

  Future<bool> _alreadyShown(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_shownIdsKey) ?? <String>[];
    return list.contains(id);
  }

  Future<void> _markShown(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_shownIdsKey) ?? <String>[];
    if (list.contains(id)) return;
    list.add(id);
    if (list.length > 500) {
      list.removeRange(0, list.length - 500);
    }
    await prefs.setStringList(_shownIdsKey, list);
  }
}