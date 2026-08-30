// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkScheduleModel _$WorkScheduleModelFromJson(Map<String, dynamic> json) =>
    _WorkScheduleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      graceMinutes: (json['grace_minutes'] as num).toInt(),
      workDays: (json['work_days'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      isDefault: json['is_default'] as bool,
      scheduleType: json['schedule_type'] as String,
      requiredMinutes: (json['required_minutes'] as num).toInt(),
      allowCheckInAfterEndTime:
          json['allow_check_in_after_end_time'] as bool? ?? true,
      geofenceEnabled: json['geofence_enabled'] as bool? ?? false,
      geofenceLat: (json['geofence_lat'] as num?)?.toDouble(),
      geofenceLng: (json['geofence_lng'] as num?)?.toDouble(),
      geofenceRadiusM: (json['geofence_radius_m'] as num?)?.toInt() ?? 100,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$WorkScheduleModelToJson(_WorkScheduleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'grace_minutes': instance.graceMinutes,
      'work_days': instance.workDays,
      'is_default': instance.isDefault,
      'schedule_type': instance.scheduleType,
      'required_minutes': instance.requiredMinutes,
      'allow_check_in_after_end_time': instance.allowCheckInAfterEndTime,
      'geofence_enabled': instance.geofenceEnabled,
      'geofence_lat': instance.geofenceLat,
      'geofence_lng': instance.geofenceLng,
      'geofence_radius_m': instance.geofenceRadiusM,
      'created_at': instance.createdAt,
    };
