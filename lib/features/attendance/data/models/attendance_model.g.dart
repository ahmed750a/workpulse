// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    _AttendanceModel(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      date: DateTime.parse(json['date'] as String),
      checkIn: json['checkIn'] as String?,
      checkOut: json['checkOut'] as String?,
      isLate: json['isLate'] as bool?,
      isAbsent: json['isAbsent'] as bool?,
    );

Map<String, dynamic> _$AttendanceModelToJson(_AttendanceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'date': instance.date.toIso8601String(),
      'checkIn': instance.checkIn,
      'checkOut': instance.checkOut,
      'isLate': instance.isLate,
      'isAbsent': instance.isAbsent,
    };
