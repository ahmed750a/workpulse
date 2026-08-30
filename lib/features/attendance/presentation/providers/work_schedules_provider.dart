import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../../data/models/work_schedule_model.dart';
import '../../data/repositories/work_schedule_repository.dart';

final workSchedulesRepositoryProvider = Provider<WorkScheduleRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return WorkScheduleRepository(client);
});

class WorkSchedulesState {
  final List<WorkScheduleModel> schedules;
  final bool isLoading;
  final String? error;

  const WorkSchedulesState({
    this.schedules = const [],
    this.isLoading = false,
    this.error,
  });

  WorkSchedulesState copyWith({
    List<WorkScheduleModel>? schedules,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WorkSchedulesState(
      schedules: schedules ?? this.schedules,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class WorkSchedulesNotifier extends Notifier<WorkSchedulesState> {
  late final WorkScheduleRepository _repository;

  @override
  WorkSchedulesState build() {
    _repository = ref.read(workSchedulesRepositoryProvider);
    ref.watch(sessionVersionProvider); // ✅
    return const WorkSchedulesState();
  }

  Future<void> loadSchedules() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final schedules = await _repository.getAllSchedules();
      state = state.copyWith(
        schedules: schedules,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<bool> deleteSchedule(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.deleteSchedule(id);
      await loadSchedules();
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }
  Future<bool> createSchedule({
    required String name,
    required String startTime,
    required String endTime,
    required int graceMinutes,
    required List<int> workDays,
    required bool isDefault,
    required String scheduleType,
    required int requiredMinutes,
    required bool allowCheckInAfterEndTime,
    required bool geofenceEnabled,
    double? geofenceLat,
    double? geofenceLng,
    required int geofenceRadiusM,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.createSchedule(
        name: name,
        startTime: startTime,
        endTime: endTime,
        graceMinutes: graceMinutes,
        workDays: workDays,
        isDefault: isDefault,
        scheduleType: scheduleType,
        requiredMinutes: requiredMinutes,
        allowCheckInAfterEndTime: allowCheckInAfterEndTime,
        geofenceEnabled: geofenceEnabled,
        geofenceLat: geofenceLat,
        geofenceLng: geofenceLng,
        geofenceRadiusM: geofenceRadiusM,
      );

      await loadSchedules();
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> updateSchedule({
    required String id,
    required String name,
    required String startTime,
    required String endTime,
    required int graceMinutes,
    required List<int> workDays,
    required bool isDefault,
    required String scheduleType,
    required int requiredMinutes,
    required bool allowCheckInAfterEndTime,
    required bool geofenceEnabled,
    double? geofenceLat,
    double? geofenceLng,
    required int geofenceRadiusM,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.updateSchedule(
        id: id,
        name: name,
        startTime: startTime,
        endTime: endTime,
        graceMinutes: graceMinutes,
        workDays: workDays,
        isDefault: isDefault,
        scheduleType: scheduleType,
        requiredMinutes: requiredMinutes,
        allowCheckInAfterEndTime: allowCheckInAfterEndTime,
        geofenceEnabled: geofenceEnabled,
        geofenceLat: geofenceLat,
        geofenceLng: geofenceLng,
        geofenceRadiusM: geofenceRadiusM,
      );

      await loadSchedules();
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }


}

final workSchedulesProvider =
NotifierProvider<WorkSchedulesNotifier, WorkSchedulesState>(
  WorkSchedulesNotifier.new,
);