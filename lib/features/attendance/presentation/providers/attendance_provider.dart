import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../../../../../core/services/work_timer_service.dart';
import '../../../../../core/services/location_tracking_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/attendance_break_model.dart';
import '../../data/models/attendance_record_model.dart';
import '../../data/models/work_schedule_model.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/work_schedule_repository.dart';

final workScheduleRepositoryProvider = Provider<WorkScheduleRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return WorkScheduleRepository(client);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  final scheduleRepo = ref.read(workScheduleRepositoryProvider);
  return AttendanceRepository(client, scheduleRepo);
});

class AttendanceState {
  final AttendanceRecordModel? todayRecord;
  final WorkScheduleModel? currentSchedule;
  final AttendanceBreakModel? activeBreak;
  final List<AttendanceBreakModel> todayBreaks;
  final int totalBreakMinutes;
  final List<AttendanceRecordModel> monthlyRecords;
  final List<AttendanceRecordModel> todayAllRecords;
  final List<Map<String, dynamic>> todayAdminAttendance;
  final List<AttendanceRecordModel> adminEmployeeRecords;
  final bool isLoading;
  final String? error;
  final bool hasPendingCheckOut;
  final double? currentLatitude;
  final double? currentLongitude;
  final double? currentDistanceMeters;
  final bool isOutsideGeofence;

  const AttendanceState({
    this.todayRecord,
    this.currentSchedule,
    this.activeBreak,
    this.todayBreaks = const [],
    this.totalBreakMinutes = 0,
    this.monthlyRecords = const [],
    this.todayAllRecords = const [],
    this.todayAdminAttendance = const [],
    this.adminEmployeeRecords = const [],
    this.isLoading = false,
    this.error,
    this.hasPendingCheckOut = false,
    this.currentLatitude,
    this.currentLongitude,
    this.currentDistanceMeters,
    this.isOutsideGeofence = false,
  });

  AttendanceState copyWith({
    AttendanceRecordModel? todayRecord,
    WorkScheduleModel? currentSchedule,
    AttendanceBreakModel? activeBreak,
    List<AttendanceBreakModel>? todayBreaks,
    int? totalBreakMinutes,
    List<AttendanceRecordModel>? monthlyRecords,
    List<AttendanceRecordModel>? todayAllRecords,
    List<Map<String, dynamic>>? todayAdminAttendance,
    List<AttendanceRecordModel>? adminEmployeeRecords,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasPendingCheckOut,
    double? currentLatitude,
    double? currentLongitude,
    double? currentDistanceMeters,
    bool? isOutsideGeofence,
    bool clearLocation = false,
    bool clearTodayRecord = false,
    bool clearActiveBreak = false,
  }) {
    return AttendanceState(
      todayRecord: clearTodayRecord ? null : todayRecord ?? this.todayRecord,
      currentSchedule: currentSchedule ?? this.currentSchedule,
      activeBreak: clearActiveBreak ? null : activeBreak ?? this.activeBreak,
      todayBreaks: todayBreaks ?? this.todayBreaks,
      totalBreakMinutes: totalBreakMinutes ?? this.totalBreakMinutes,
      monthlyRecords: monthlyRecords ?? this.monthlyRecords,
      todayAllRecords: todayAllRecords ?? this.todayAllRecords,
      todayAdminAttendance: todayAdminAttendance ?? this.todayAdminAttendance,
      adminEmployeeRecords: adminEmployeeRecords ?? this.adminEmployeeRecords,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      hasPendingCheckOut: hasPendingCheckOut ?? this.hasPendingCheckOut,
      currentLatitude: clearLocation ? null : currentLatitude ?? this.currentLatitude,
      currentLongitude: clearLocation ? null : currentLongitude ?? this.currentLongitude,
      currentDistanceMeters: clearLocation ? null : currentDistanceMeters ?? this.currentDistanceMeters,
      isOutsideGeofence: isOutsideGeofence ?? this.isOutsideGeofence,    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  late AttendanceRepository _repository;
  bool _isMonitoring = false;
  bool _isSyncing = false;
  StreamSubscription<LiveLocationStatus>? _locationSub;
  @override
  AttendanceState build() {
    // ✅ يعيد البناء عند كل تسجيل خروج أو تغير مستخدم
    ref.watch(sessionVersionProvider);
    ref.watch(authProvider.select((s) => s.user?.id));

    _repository = ref.read(attendanceRepositoryProvider);
    _restoreState();
    _startConnectivityMonitoring();
    _startLocationListener();
    return const AttendanceState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

  bool _isNetworkError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('socketexception') ||
        message.contains('failed host lookup') ||
        message.contains('network is unreachable') ||
        message.contains('connection timed out') ||
        message.contains('connection refused') ||
        message.contains('clientexception') ||
        message.contains('timeout') ||
        message.contains('xmlhttprequest error') ||
        message.contains('authretryablefetchexception');
  }

  void _startConnectivityMonitoring() {
    if (_isMonitoring) return;
    _isMonitoring = true;

    final subscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isEmpty) return;
      if (results.first != ConnectivityResult.none) {
        _syncPendingCheckOut();
      }
    });

    ref.onDispose(() {
      subscription.cancel();
      _isMonitoring = false;
    });
  }

  void _startLocationListener() {
    _locationSub?.cancel();

    _locationSub =
        LocationTrackingService.instance.locationStream.listen((live) {
          state = state.copyWith(
            currentLatitude: live.latitude,
            currentLongitude: live.longitude,
            currentDistanceMeters: live.distanceMeters,
            isOutsideGeofence: live.isOutside,
          );

          _repository.syncMyLiveLocation(
            lat: live.latitude,
            lng: live.longitude,
          );
        });

    ref.onDispose(() async {
      await _locationSub?.cancel();
      await LocationTrackingService.instance.stop();
    });
  }
  Future<void> loadAdminAttendanceByMonth({
    required DateTime month,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final rows = await _repository.getAdminAttendanceRecordsByMonth(
        month: month,
      );
      state = state.copyWith(
        todayAdminAttendance: rows, // نعيد استخدام نفس الحقل الحالي
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> loadTodayAttendanceForAdmin() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final rows = await _repository.getTodayAttendanceForAdmin();
      state = state.copyWith(
        todayAdminAttendance: rows,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> loadAdminEmployeeMonthlyRecords({
    required String employeeId,
    required DateTime month,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records = await _repository.getEmployeeMonthlyRecordsForAdmin(
        employeeId: employeeId,
        month: month,
      );

      state = state.copyWith(
        adminEmployeeRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> _syncLocationTracking({
    required WorkScheduleModel? schedule,
    required AttendanceRecordModel? record,
  }) async {
    final isInsideDuty = record?.checkInAt != null && record?.checkOutAt == null;

    final canTrack = schedule?.geofenceEnabled == true &&
        schedule?.geofenceLat != null &&
        schedule?.geofenceLng != null;

    if (isInsideDuty && canTrack) {
      await LocationTrackingService.instance.start(
        targetLat: schedule!.geofenceLat!,
        targetLng: schedule.geofenceLng!,
        radiusMeters: schedule.geofenceRadiusM,
      );
    } else {
      await LocationTrackingService.instance.stop();
      state = state.copyWith(
        clearLocation: true,
        isOutsideGeofence: false,
      );
    }
  }

  Future<void> _restoreState() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(hasPendingCheckOut: false);
      return;
    }

    final hasPending =
    await WorkTimerService.instance.hasPendingCheckOut(userId: userId);

    state = state.copyWith(hasPendingCheckOut: hasPending);
    await loadTodayRecord();
  }

  Future<void> _syncPendingCheckOut() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final userId = _currentUserId;
    if (userId == null) {
      _isSyncing = false;
      return;
    }

    final actualCheckOutTime =
    await WorkTimerService.instance.getPendingCheckOutTime(userId: userId);
    if (actualCheckOutTime == null) {
      _isSyncing = false;
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final existing = await _repository.getTodayRecord();

      if (existing != null && existing.checkOutAt == null) {
        final record = await _repository.checkOutWithTime(actualCheckOutTime);

        await WorkTimerService.instance.stop(userId: userId);

        await _reloadAttendanceSnapshot(
          todayRecord: record,
          isLoading: false,
          hasPendingCheckOut: false,
        );

        if (kDebugMode) {
          print('✅ تمت مزامنة الانصراف بوقت: $actualCheckOutTime');
        }
      } else {
        await WorkTimerService.instance.stop(userId: userId);
        state = state.copyWith(
          hasPendingCheckOut: false,
          isLoading: false,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ فشل مزامنة الانصراف: $e');
      }
      state = state.copyWith(
        error: 'فشلت المزامنة التلقائية، حاول مجدداً يدوياً',
        isLoading: false,
      );
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _reloadAttendanceSnapshot({
    AttendanceRecordModel? todayRecord,
    bool isLoading = false,
    bool? hasPendingCheckOut,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final schedule = await _repository.getMyWorkSchedule();
    final record = todayRecord ?? await _repository.getTodayRecord();
    final activeBreak = await _repository.getActiveBreak();
    final todayBreaks = await _repository.getTodayBreaks();
    final totalBreakMinutes = await _repository.getTodayBreakMinutes();

    await _syncLocationTracking(
      schedule: schedule,
      record: record,
    );

    state = state.copyWith(
      todayRecord: record,
      currentSchedule: schedule,
      activeBreak: activeBreak,
      clearActiveBreak: activeBreak == null,
      todayBreaks: todayBreaks,
      totalBreakMinutes: totalBreakMinutes,
      isLoading: isLoading,
      hasPendingCheckOut: hasPendingCheckOut,
    );
  }

  Future<void> loadTodayRecord() async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final schedule = await _repository.getMyWorkSchedule();
      final record = await _repository.getTodayRecord();
      final activeBreak = await _repository.getActiveBreak();
      final todayBreaks = await _repository.getTodayBreaks();
      final totalBreakMinutes = await _repository.getTodayBreakMinutes();

      await _syncLocationTracking(
        schedule: schedule,
        record: record,
      );

      if (record?.checkInAt != null && record?.checkOutAt == null) {
        if (activeBreak != null) {
          // أثناء إذن خروج/عودة أو استراحة نشطة نوقف عداد الدوام
          await WorkTimerService.instance.stop(userId: userId);
        } else {
          await WorkTimerService.instance.start(
            userId: userId,
            checkInTime: DateTime.parse(record!.checkInAt!).toLocal(),
          );
        }
      } else if (record?.checkOutAt != null) {
        await WorkTimerService.instance.stop(userId: userId);
      }

      state = state.copyWith(
        todayRecord: record,
        currentSchedule: schedule,
        activeBreak: activeBreak,
        clearActiveBreak: activeBreak == null,
        todayBreaks: todayBreaks,
        totalBreakMinutes: totalBreakMinutes,
        isLoading: false,
        hasPendingCheckOut: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> checkIn() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final record = await _repository.checkIn();
      await _reloadAttendanceSnapshot(todayRecord: record, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> checkOut() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final record = await _repository.checkOut();
      await WorkTimerService.instance.stop(userId: userId);

      await _reloadAttendanceSnapshot(
        todayRecord: record,
        isLoading: false,
        hasPendingCheckOut: false,
      );
    } catch (e) {
      if (_isNetworkError(e)) {
        // 1) نحفظ وقت الانصراف كمعلّق للمزامنة
        await WorkTimerService.instance.savePendingCheckOut(userId: userId);

        // 2) نوقف العداد محلياً ونلغي الإشعار، لكن نُبقي وقت الانصراف المعلّق
        await WorkTimerService.instance.finishLocallyForPendingCheckout(
          userId: userId,
        );

        state = state.copyWith(
          error: 'لا يوجد اتصال مستقر. تم حفظ وقت الانصراف محلياً وسيتم إرساله عند عودة الإنترنت.',
          isLoading: false,
          hasPendingCheckOut: true,
        );
        return;
      }

      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        hasPendingCheckOut: false,
      );
    }
  }

  Future<void> startBreak() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.startBreak();
      await _reloadAttendanceSnapshot(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> endBreak() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.endBreak();
      await _reloadAttendanceSnapshot(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }


  Future<void> startExitReturnPermission() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.startExitReturnPermission();

      // وقف عداد الدوام الرسمي أثناء استخدام إذن الخروج والعودة
      await WorkTimerService.instance.stop(userId: userId);

      await _reloadAttendanceSnapshot(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> endExitReturnPermission() async {
    final userId = _currentUserId;
    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.endExitReturnPermission();

      // بعد العودة نستأنف عداد الدوام إذا اليوم ما زال مفتوح
      final record = await _repository.getTodayRecord();
      if (record?.checkInAt != null && record?.checkOutAt == null) {
        await WorkTimerService.instance.start(
          userId: userId,
          checkInTime: DateTime.parse(record!.checkInAt!).toLocal(),
        );
      }

      await _reloadAttendanceSnapshot(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadMonthlyRecords([DateTime? month]) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final targetMonth = month ?? DateTime.now();

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records = await _repository.getMyMonthlyRecords(targetMonth);
      state = state.copyWith(monthlyRecords: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTodayAllRecords() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records = await _repository.getTodayAllRecords();
      state = state.copyWith(todayAllRecords: records, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final attendanceProvider =
NotifierProvider.autoDispose<AttendanceNotifier, AttendanceState>(
  AttendanceNotifier.new,
);