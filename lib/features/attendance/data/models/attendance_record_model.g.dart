// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecordModel _$AttendanceRecordModelFromJson(
        Map<String, dynamic> json) =>
    _AttendanceRecordModel(
      id: json['id'] as String,
      approvedEarlyLeaveMinutes:
          (json['approved_early_leave_minutes'] as num).toInt(),
      unapprovedEarlyLeaveMinutes:
          (json['unapproved_early_leave_minutes'] as num).toInt(),
      employeeId: json['employee_id'] as String,
      attendanceDate: json['attendance_date'] as String,
      checkInAt: json['check_in_at'] as String?,
      checkOutAt: json['check_out_at'] as String?,
      status: json['status'] as String,
      lateMinutes: (json['late_minutes'] as num).toInt(),
      totalLateMinutes: (json['total_late_minutes'] as num?)?.toInt() ?? 0,
      approvedLateMinutes:
          (json['approved_late_minutes'] as num?)?.toInt() ?? 0,
      unapprovedLateMinutes:
          (json['unapproved_late_minutes'] as num?)?.toInt() ?? 0,
      earlyLeaveMinutes: (json['early_leave_minutes'] as num).toInt(),
      workedMinutes: (json['worked_minutes'] as num).toInt(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AttendanceRecordModelToJson(
        _AttendanceRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'approved_early_leave_minutes': instance.approvedEarlyLeaveMinutes,
      'unapproved_early_leave_minutes': instance.unapprovedEarlyLeaveMinutes,
      'employee_id': instance.employeeId,
      'attendance_date': instance.attendanceDate,
      'check_in_at': instance.checkInAt,
      'check_out_at': instance.checkOutAt,
      'status': instance.status,
      'late_minutes': instance.lateMinutes,
      'total_late_minutes': instance.totalLateMinutes,
      'approved_late_minutes': instance.approvedLateMinutes,
      'unapproved_late_minutes': instance.unapprovedLateMinutes,
      'early_leave_minutes': instance.earlyLeaveMinutes,
      'worked_minutes': instance.workedMinutes,
      'notes': instance.notes,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
