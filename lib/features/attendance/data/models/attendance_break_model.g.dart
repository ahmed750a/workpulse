// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_break_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceBreakModel _$AttendanceBreakModelFromJson(
        Map<String, dynamic> json) =>
    _AttendanceBreakModel(
      id: json['id'] as String,
      attendanceRecordId: json['attendance_record_id'] as String,
      employeeId: json['employee_id'] as String,
      breakStartAt: json['break_start_at'] as String,
      breakEndAt: json['break_end_at'] as String?,
      breakMinutes: (json['break_minutes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'active',
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$AttendanceBreakModelToJson(
        _AttendanceBreakModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'attendance_record_id': instance.attendanceRecordId,
      'employee_id': instance.employeeId,
      'break_start_at': instance.breakStartAt,
      'break_end_at': instance.breakEndAt,
      'break_minutes': instance.breakMinutes,
      'status': instance.status,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
