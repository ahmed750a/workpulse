import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../../core/services/work_timer_service.dart';
import '../../../../../app/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/attendance_record_model.dart';
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
  final List<AttendanceRecordModel> monthlyRecords;
  final List<AttendanceRecordModel> todayAllRecords;
  final bool isLoading;
  final String? error;
  final bool hasPendingCheckOut;

  const AttendanceState({
    this.todayRecord,
    this.monthlyRecords = const [],
    this.todayAllRecords = const [],
    this.isLoading = false,
    this.error,
    this.hasPendingCheckOut = false,
  });

  AttendanceState copyWith({
    AttendanceRecordModel? todayRecord,
    List<AttendanceRecordModel>? monthlyRecords,
    List<AttendanceRecordModel>? todayAllRecords,
    bool? isLoading,
    String? error,
    bool clearError = false,         // ✅ إصلاح copyWith
    bool? hasPendingCheckOut,
    bool clearTodayRecord = false,
  }) {
    return AttendanceState(
      todayRecord:
      clearTodayRecord ? null : todayRecord ?? this.todayRecord,
      monthlyRecords: monthlyRecords ?? this.monthlyRecords,
      todayAllRecords: todayAllRecords ?? this.todayAllRecords,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error, // ✅
      hasPendingCheckOut:
      hasPendingCheckOut ?? this.hasPendingCheckOut,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  late final AttendanceRepository _repository;
  bool _isMonitoring = false;
  bool _isSyncing = false;

  @override
  AttendanceState build() {
    _repository = ref.read(attendanceRepositoryProvider);
    _restoreState();
    _startConnectivityMonitoring();
    return const AttendanceState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

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

  Future<void> _syncPendingCheckOut() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final userId = _currentUserId;
    if (userId == null) {
      _isSyncing = false;
      return;
    }

    // ✅ نجلب الوقت الفعلي المحفوظ
    final actualCheckOutTime =
    await WorkTimerService.instance.getPendingCheckOutTime();

    if (actualCheckOutTime == null) {
      _isSyncing = false;
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final existing = await _repository.getTodayRecord(userId);

      if (existing != null && existing.checkOutAt == null) {
        // ✅ نستخدم checkOutWithTime بالوقت الفعلي
        final record = await _repository.checkOutWithTime(
          userId,
          actualCheckOutTime,
        );

        await WorkTimerService.instance.stop();

        state = state.copyWith(
          todayRecord: record,
          isLoading: false,
          hasPendingCheckOut: false,
        );

        if (kDebugMode) {
          print('✅ تمت مزامنة الانصراف بوقت: $actualCheckOutTime');
        }
      } else {
        await WorkTimerService.instance.stop();
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

  Future<void> _restoreState() async {
    final hasPending =
    await WorkTimerService.instance.hasPendingCheckOut();
    state = state.copyWith(hasPendingCheckOut: hasPending);
    await loadTodayRecord();
  }

  Future<void> loadTodayRecord() async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final record = await _repository.getTodayRecord(userId);

      if (record?.checkInAt != null && record?.checkOutAt == null) {
        await WorkTimerService.instance.start(
          checkInTime: DateTime.parse(record!.checkInAt!).toLocal(),
        );
      } else if (record?.checkOutAt != null) {
        await WorkTimerService.instance.stop();
      }

      state = state.copyWith(
        todayRecord: record,
        isLoading: false,
        hasPendingCheckOut: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
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
      final record = await _repository.checkIn(userId);
      state = state.copyWith(todayRecord: record, isLoading: false);
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
      // ✅ انصراف عادي بـ DateTime.now()
      final record = await _repository.checkOut(userId);
      await WorkTimerService.instance.stop();

      state = state.copyWith(
        todayRecord: record,
        isLoading: false,
        hasPendingCheckOut: false,
      );
    } catch (e) {
      // ✅ حفظ وقت الضغط الفعلي محلياً
      await WorkTimerService.instance.savePendingCheckOut();

      state = state.copyWith(
        error: 'تم حفظ الانصراف محلياً. سيتم المزامنة عند عودة الإنترنت.',
        isLoading: false,
        hasPendingCheckOut: true,
      );
    }
  }

  Future<void> loadMonthlyRecords([DateTime? month]) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final targetMonth = month ?? DateTime.now();
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final records =
      await _repository.getMyMonthlyRecords(userId, targetMonth);
      state = state.copyWith(
        monthlyRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final attendanceProvider =
NotifierProvider<AttendanceNotifier, AttendanceState>(
  AttendanceNotifier.new,
);