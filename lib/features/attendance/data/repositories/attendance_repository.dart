import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../core/services/work_timer_service.dart';
import '../models/attendance_record_model.dart';
import 'work_schedule_repository.dart';

class AttendanceRepository {
  final SupabaseClient _client;
  final WorkScheduleRepository _scheduleRepository;

  AttendanceRepository(this._client, this._scheduleRepository);

  String _dateOnly(DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  DateTime _scheduleTimeToToday(String time) {
    final now = DateTime.now();
    final parts = time.split(':');

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  Future<AttendanceRecordModel?> getTodayRecord(String employeeId) async {
    final data = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .maybeSingle();

    if (data == null) return null;
    return AttendanceRecordModel.fromJson(data);
  }

  Future<AttendanceRecordModel> checkIn(String employeeId) async {
    final schedule = await _scheduleRepository.getScheduleForEmployee(employeeId);
    final now = DateTime.now();

    if (!schedule.workDays.contains(now.weekday)) {
      throw Exception('اليوم ليس ضمن أيام الدوام الرسمية');
    }

    final existing = await getTodayRecord(employeeId);
    if (existing != null) {
      throw Exception('تم تسجيل الحضور مسبقاً لهذا اليوم');
    }

    int lateMinutes = 0;
    String status = 'checked_in';

    if (schedule.scheduleType == 'fixed') {
      final officialStart = _scheduleTimeToToday(schedule.startTime);
      final allowedStart =
      officialStart.add(Duration(minutes: schedule.graceMinutes));

      if (now.isAfter(allowedStart)) {
        lateMinutes = now.difference(officialStart).inMinutes;
        status = 'late';
      }
    }

    final data = await _client
        .from('attendance_records')
        .insert({
      'employee_id': employeeId,
      'attendance_date': _dateOnly(now),
      'check_in_at': now.toUtc().toIso8601String(),
      'status': status,
      'late_minutes': lateMinutes,
      'early_leave_minutes': 0,
      'worked_minutes': 0,
      'updated_at': now.toUtc().toIso8601String(),
    })
        .select()
        .single();

    await WorkTimerService.instance.start(checkInTime: now);

    return AttendanceRecordModel.fromJson(data);
  }

  Future<AttendanceRecordModel> checkOut(String employeeId) async {
    final existing = await getTodayRecord(employeeId);

    if (existing == null) {
      throw Exception('لا يوجد تسجيل حضور لهذا اليوم');
    }

    if (existing.checkInAt == null) {
      throw Exception('سجل الحضور غير مكتمل');
    }

    if (existing.checkOutAt != null) {
      throw Exception('تم تسجيل الانصراف مسبقاً لهذا اليوم');
    }

    final schedule = await _scheduleRepository.getScheduleForEmployee(employeeId);

    final now = DateTime.now();
    final checkInAt = DateTime.parse(existing.checkInAt!).toLocal();

    int workedMinutes = now.difference(checkInAt).inMinutes;
    if (workedMinutes < 0) workedMinutes = 0;

    int earlyLeaveMinutes = 0;
    String status = 'checked_out';
    if (schedule.scheduleType == 'fixed' &&
        schedule.allowCheckInAfterEndTime == false) {

      final officialEnd = _scheduleTimeToToday(schedule.endTime);

      if (now.isAfter(officialEnd)) {
        throw Exception(
          'انتهى وقت الدوام الرسمي ولا يمكن تسجيل الحضور',
        );
      }
    }
    if (schedule.scheduleType == 'fixed') {
      final officialEnd = _scheduleTimeToToday(schedule.endTime);

      if (now.isBefore(officialEnd)) {
        earlyLeaveMinutes = officialEnd.difference(now).inMinutes;
      }

      if (existing.lateMinutes > 0 && earlyLeaveMinutes > 0) {
        status = 'late_and_early_leave';
      } else if (existing.lateMinutes > 0) {
        status = 'late_checked_out';
      } else if (earlyLeaveMinutes > 0) {
        status = 'early_leave';
      }
    } else {
      final remaining = schedule.requiredMinutes - workedMinutes;

      if (remaining > 0) {
        status = 'hours_incomplete';
      } else if (workedMinutes > schedule.requiredMinutes) {
        status = 'hours_completed_with_overtime';
      } else {
        status = 'hours_completed';
      }
    }

    final data = await _client
        .from('attendance_records')
        .update({
      'check_out_at': now.toUtc().toIso8601String(),
      'worked_minutes': workedMinutes,
      'early_leave_minutes': earlyLeaveMinutes,
      'status': status,
      'updated_at': now.toUtc().toIso8601String(),
    })
        .eq('id', existing.id)
        .select()
        .single();

    await WorkTimerService.instance.stop();

    return AttendanceRecordModel.fromJson(data);
  }

  Future<List<AttendanceRecordModel>> getMyMonthlyRecords(
      String employeeId,
      DateTime month,
      ) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final data = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .gte('attendance_date', _dateOnly(start))
        .lt('attendance_date', _dateOnly(end))
        .order('attendance_date', ascending: false);

    return data
        .map<AttendanceRecordModel>(
          (item) => AttendanceRecordModel.fromJson(item),
    )
        .toList();
  }

  Future<List<AttendanceRecordModel>> getTodayAllRecords() async {
    final data = await _client
        .from('attendance_records')
        .select()
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .order('created_at', ascending: false);

    return data
        .map<AttendanceRecordModel>(
          (item) => AttendanceRecordModel.fromJson(item),
    )
        .toList();
  }
}