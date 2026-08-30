import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/work_schedule_model.dart';

class WorkScheduleRepository {
  final SupabaseClient _client;

  WorkScheduleRepository(this._client);

  Future<WorkScheduleModel> getDefaultSchedule() async {
    final data = await _client
        .from('work_schedules')
        .select()
        .eq('is_default', true)
        .order('created_at', ascending: false)
        .limit(1);

    if (data.isEmpty) {
      throw Exception('لا يوجد جدول دوام افتراضي. يرجى إنشاء جدول افتراضي من إعدادات الدوام.');
    }

    return WorkScheduleModel.fromJson(data.first);
  }
  Future<void> createSchedule({
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
    if (isDefault) {
      await _client
          .from('work_schedules')
          .update({'is_default': false})
          .eq('is_default', true);
    }

    await _client.from('work_schedules').insert({
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'grace_minutes': graceMinutes,
      'work_days': workDays,
      'is_default': isDefault,
      'schedule_type': scheduleType,
      'required_minutes': requiredMinutes,
      'allow_check_in_after_end_time': allowCheckInAfterEndTime,
      'geofence_enabled': geofenceEnabled,
      'geofence_lat': geofenceEnabled ? geofenceLat : null,
      'geofence_lng': geofenceEnabled ? geofenceLng : null,
      'geofence_radius_m': geofenceRadiusM,
    });
  }

  Future<void> updateSchedule({
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
    if (isDefault) {
      await _client
          .from('work_schedules')
          .update({'is_default': false})
          .neq('id', id)
          .eq('is_default', true);
    }

    await _client.from('work_schedules').update({
      'name': name,
      'start_time': startTime,
      'end_time': endTime,
      'grace_minutes': graceMinutes,
      'work_days': workDays,
      'is_default': isDefault,
      'schedule_type': scheduleType,
      'required_minutes': requiredMinutes,
      'allow_check_in_after_end_time': allowCheckInAfterEndTime,
      'geofence_enabled': geofenceEnabled,
      'geofence_lat': geofenceEnabled ? geofenceLat : null,
      'geofence_lng': geofenceEnabled ? geofenceLng : null,
      'geofence_radius_m': geofenceRadiusM,
    }).eq('id', id);
  }
  Future<void> deleteSchedule(String id) async {
    final schedule = await _client
        .from('work_schedules')
        .select('id, is_default')
        .eq('id', id)
        .maybeSingle();

    if (schedule == null) {
      throw Exception('جدول الدوام غير موجود');
    }

    if (schedule['is_default'] == true) {
      throw Exception('لا يمكن حذف جدول الدوام الافتراضي');
    }

    final assignedProfiles = await _client
        .from('profiles')
        .select('id')
        .eq('work_schedule_id', id);

    if (assignedProfiles.isNotEmpty) {
      throw Exception(
        'لا يمكن حذف هذا الجدول لأنه مرتبط بموظفين. قم بتغيير دوام الموظفين أولاً.',
      );
    }

    await _client
        .from('work_schedules')
        .delete()
        .eq('id', id);
  }
  Future<List<WorkScheduleModel>> getAllSchedules() async {
    final data = await _client
        .from('work_schedules')
        .select()
        .order('created_at', ascending: false);

    return data
        .map<WorkScheduleModel>(
          (item) => WorkScheduleModel.fromJson(item),
    )
        .toList();
  }
  Future<WorkScheduleModel> getScheduleForEmployee(String employeeId) async {
    final profile = await _client
        .from('profiles')
        .select('work_schedule_id')
        .eq('id', employeeId)
        .maybeSingle();

    final scheduleId = profile?['work_schedule_id'];

    if (scheduleId == null) {
      return getDefaultSchedule();
    }

    final data = await _client
        .from('work_schedules')
        .select()
        .eq('id', scheduleId)
        .single();

    return WorkScheduleModel.fromJson(data);
  }
}