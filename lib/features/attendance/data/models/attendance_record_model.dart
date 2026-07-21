import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_record_model.freezed.dart';
part 'attendance_record_model.g.dart';

@freezed
abstract class AttendanceRecordModel with _$AttendanceRecordModel {
  const factory AttendanceRecordModel({
    required String id,
    @JsonKey(name: 'approved_early_leave_minutes')
    required int approvedEarlyLeaveMinutes,

    @JsonKey(name: 'unapproved_early_leave_minutes')
    required int unapprovedEarlyLeaveMinutes,
    @JsonKey(name: 'employee_id')
    required String employeeId,

    @JsonKey(name: 'attendance_date')
    required String attendanceDate,

    @JsonKey(name: 'check_in_at')
    String? checkInAt,

    @JsonKey(name: 'check_out_at')
    String? checkOutAt,

    required String status,

    @JsonKey(name: 'late_minutes')
    required int lateMinutes,

    @JsonKey(name: 'total_late_minutes')
    @Default(0)
    int totalLateMinutes,

    @JsonKey(name: 'approved_late_minutes')
    @Default(0)
    int approvedLateMinutes,

    @JsonKey(name: 'unapproved_late_minutes')
    @Default(0)
    int unapprovedLateMinutes,

    @JsonKey(name: 'early_leave_minutes')
    required int earlyLeaveMinutes,

    @JsonKey(name: 'worked_minutes')
    required int workedMinutes,

    String? notes,

    @JsonKey(name: 'created_at')
    String? createdAt,

    @JsonKey(name: 'updated_at')
    String? updatedAt,
  }) = _AttendanceRecordModel;

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordModelFromJson(json);
}