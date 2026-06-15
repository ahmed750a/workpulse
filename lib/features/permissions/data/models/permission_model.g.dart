// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'permission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PermissionModel _$PermissionModelFromJson(Map<String, dynamic> json) =>
    _PermissionModel(
      id: json['id'] as String,
      employeeId: json['employee_id'] as String,
      permissionDate: json['permission_date'] as String,
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      totalMinutes: (json['total_minutes'] as num).toInt(),
      type: json['type'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      reviewedBy: json['reviewed_by'] as String?,
      reviewedAt: json['reviewed_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$PermissionModelToJson(_PermissionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employee_id': instance.employeeId,
      'permission_date': instance.permissionDate,
      'start_time': instance.startTime,
      'end_time': instance.endTime,
      'total_minutes': instance.totalMinutes,
      'type': instance.type,
      'reason': instance.reason,
      'status': instance.status,
      'reviewed_by': instance.reviewedBy,
      'reviewed_at': instance.reviewedAt,
      'rejection_reason': instance.rejectionReason,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
