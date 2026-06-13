import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final scheduleRepository = ref.read(workScheduleRepositoryProvider);
  return AttendanceRepository(client, scheduleRepository);
});

class AttendanceState {
  final AttendanceRecordModel? todayRecord;
  final List<AttendanceRecordModel> monthlyRecords;
  final List<AttendanceRecordModel> todayAllRecords;
  final bool isLoading;
  final String? error;

  const AttendanceState({
    this.todayRecord,
    this.monthlyRecords = const [],
    this.todayAllRecords = const [],
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    AttendanceRecordModel? todayRecord,
    List<AttendanceRecordModel>? monthlyRecords,
    List<AttendanceRecordModel>? todayAllRecords,
    bool? isLoading,
    String? error,
    bool clearTodayRecord = false,
  }) {
    return AttendanceState(
      todayRecord: clearTodayRecord ? null : todayRecord ?? this.todayRecord,
      monthlyRecords: monthlyRecords ?? this.monthlyRecords,
      todayAllRecords: todayAllRecords ?? this.todayAllRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceNotifier extends Notifier<AttendanceState> {
  late final AttendanceRepository _repository;

  @override
  AttendanceState build() {
    _repository = ref.read(attendanceRepositoryProvider);
    return const AttendanceState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

  Future<void> loadTodayRecord() async {
    final userId = _currentUserId;

    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final record = await _repository.getTodayRecord(userId);

      if (record?.checkInAt != null && record?.checkOutAt == null) {
        await WorkTimerService.instance.start(
          checkInTime: DateTime.parse(record!.checkInAt!).toLocal(),
        );
      }

      if (record?.checkOutAt != null) {
        await WorkTimerService.instance.stop();
      }

      state = state.copyWith(
        todayRecord: record,
        isLoading: false,
        clearTodayRecord: record == null,
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

    state = state.copyWith(isLoading: true, error: null);

    try {
      final record = await _repository.checkIn(userId);

      state = state.copyWith(
        todayRecord: record,
        isLoading: false,
      );
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

    state = state.copyWith(isLoading: true, error: null);

    try {
      final record = await _repository.checkOut(userId);

      state = state.copyWith(
        todayRecord: record,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadMonthlyRecords([DateTime? month]) async {
    final userId = _currentUserId;

    if (userId == null) {
      state = state.copyWith(error: 'المستخدم غير مسجل الدخول');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final records = await _repository.getMyMonthlyRecords(
        userId,
        month ?? DateTime.now(),
      );

      state = state.copyWith(
        monthlyRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadTodayAllRecords() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final records = await _repository.getTodayAllRecords();

      state = state.copyWith(
        todayAllRecords: records,
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