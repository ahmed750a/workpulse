import 'package:freezed_annotation/freezed_annotation.dart';

part 'employee_model.freezed.dart';
part 'employee_model.g.dart';

@freezed
abstract class EmployeeModel with _$EmployeeModel {
  const factory EmployeeModel({
    required String id,
    required String email,

    @JsonKey(name: 'full_name')
    required String fullName,

    String? role,
    String? department,
    @JsonKey(name: 'work_schedule_id')
    String? workScheduleId,
    @JsonKey(name: 'is_active')
    bool? isActive,

    @JsonKey(name: 'created_at')
    String? createdAt,
  }) = _EmployeeModel;

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);
}