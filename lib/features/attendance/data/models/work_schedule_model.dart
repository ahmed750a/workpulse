import 'package:freezed_annotation/freezed_annotation.dart';

part 'work_schedule_model.freezed.dart';
part 'work_schedule_model.g.dart';

@freezed
abstract class WorkScheduleModel with _$WorkScheduleModel {
  const factory WorkScheduleModel({
    required String id,
    required String name,

    @JsonKey(name: 'start_time')
    required String startTime,

    @JsonKey(name: 'end_time')
    required String endTime,

    @JsonKey(name: 'grace_minutes')
    required int graceMinutes,

    @JsonKey(name: 'work_days')
    required List<int> workDays,

    @JsonKey(name: 'is_default')
    required bool isDefault,

    @JsonKey(name: 'schedule_type')
    required String scheduleType,

    @JsonKey(name: 'required_minutes')
    required int requiredMinutes,
    @JsonKey(name: 'allow_check_in_after_end_time')
    @Default(true)
    bool allowCheckInAfterEndTime,
    @JsonKey(name: 'created_at')
    String? createdAt,
  }) = _WorkScheduleModel;

  factory WorkScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$WorkScheduleModelFromJson(json);

}