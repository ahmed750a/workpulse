import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';

class LiveLocationStatus {
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final bool isOutside;

  const LiveLocationStatus({
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.isOutside,
  });
}

class LocationTrackingService {
  LocationTrackingService._();

  static final LocationTrackingService instance = LocationTrackingService._();

  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  final StreamController<LiveLocationStatus> _locationController =
  StreamController<LiveLocationStatus>.broadcast();

  Stream<LiveLocationStatus> get locationStream => _locationController.stream;

  StreamSubscription<Position>? _positionSub;

  double? _targetLat;
  double? _targetLng;
  int _radiusMeters = 100;

  DateTime? _lastOutsideNotificationTime;
  static const int _outsideNotificationCooldownMinutes = 5;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);
  }

  Future<void> start({
    required double targetLat,
    required double targetLng,
    required int radiusMeters,
  }) async {
    await stop();

    _targetLat = targetLat;
    _targetLng = targetLng;
    _radiusMeters = radiusMeters;

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('خدمة الموقع غير مفعلة على الجهاز.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('صلاحية الموقع مرفوضة. يرجى السماح بالموقع.');
    }

    final firstPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final firstDistance = Geolocator.distanceBetween(
      firstPosition.latitude,
      firstPosition.longitude,
      _targetLat!,
      _targetLng!,
    );

    final firstOutside = firstDistance > _radiusMeters;

    _locationController.add(
      LiveLocationStatus(
        latitude: firstPosition.latitude,
        longitude: firstPosition.longitude,
        distanceMeters: firstDistance,
        isOutside: firstOutside,
      ),
    );

    if (firstOutside) {
      await _notifyOutsideOnceWithCooldown(firstDistance);
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 1,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) async {
      if (_targetLat == null || _targetLng == null) return;

      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        _targetLat!,
        _targetLng!,
      );

      final outside = distance > _radiusMeters;

      _locationController.add(
        LiveLocationStatus(
          latitude: position.latitude,
          longitude: position.longitude,
          distanceMeters: distance,
          isOutside: outside,
        ),
      );

      if (outside) {
        await _notifyOutsideOnceWithCooldown(distance);
      }
    });
  }

  Future<void> _notifyOutsideOnceWithCooldown(double distance) async {
    final now = DateTime.now();

    if (_lastOutsideNotificationTime != null) {
      final diff = now.difference(_lastOutsideNotificationTime!);
      if (diff.inMinutes < _outsideNotificationCooldownMinutes) return;
    }

    _lastOutsideNotificationTime = now;

    const androidDetails = AndroidNotificationDetails(
      'workpulse_geofence',
      'WorkPulse Geofence',
      channelDescription: 'Geofence alert while on duty',
      importance: Importance.high,
      priority: Priority.high,
      onlyAlertOnce: true,
      playSound: false,
      enableVibration: false,
    );

    await _notifications.show(
      1001,
      'تنبيه موقع الدوام',
      'أنت الآن خارج نطاق الدوام المسموح (${distance.toStringAsFixed(0)} متر).',
      const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> stop() async {
    await _positionSub?.cancel();
    _positionSub = null;
    _targetLat = null;
    _targetLng = null;
  }
}