import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_break_model.freezed.dart';
part 'attendance_break_model.g.dart';

@freezed
abstract class AttendanceBreakModel with _$AttendanceBreakModel {
  const factory AttendanceBreakModel({
    required String id,

    @JsonKey(name: 'attendance_record_id')
    required String attendanceRecordId,

    @JsonKey(name: 'employee_id')
    required String employeeId,

    @JsonKey(name: 'break_start_at')
    required String breakStartAt,

    @JsonKey(name: 'break_end_at')
    String? breakEndAt,

    @JsonKey(name: 'break_minutes')
    @Default(0)
    int breakMinutes,

    @Default('active')
    String status,

    @JsonKey(name: 'created_at')
    String? createdAt,

    @JsonKey(name: 'updated_at')
    String? updatedAt,
  }) = _AttendanceBreakModel;

  factory AttendanceBreakModel.fromJson(Map<String, dynamic> json) =>
      _$AttendanceBreakModelFromJson(json);
}