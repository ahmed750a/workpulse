import 'package:freezed_annotation/freezed_annotation.dart';

part 'permission_model.freezed.dart';
part 'permission_model.g.dart';

@freezed
abstract class PermissionModel with _$PermissionModel {
  const factory PermissionModel({
    required String id,

    @JsonKey(name: 'employee_id')
    required String employeeId,

    @JsonKey(name: 'permission_date')
    required String permissionDate,

    @JsonKey(name: 'start_time')
    required String startTime,

    @JsonKey(name: 'end_time')
    required String endTime,

    @JsonKey(name: 'total_minutes')
    required int totalMinutes,

    required String type,
    required String reason,
    required String status,

    @JsonKey(name: 'reviewed_by')
    String? reviewedBy,

    @JsonKey(name: 'reviewed_at')
    String? reviewedAt,

    @JsonKey(name: 'rejection_reason')
    String? rejectionReason,

    @JsonKey(name: 'created_at')
    String? createdAt,

    @JsonKey(name: 'updated_at')
    String? updatedAt,
  }) = _PermissionModel;

  factory PermissionModel.fromJson(Map<String, dynamic> json) =>
      _$PermissionModelFromJson(json);
}