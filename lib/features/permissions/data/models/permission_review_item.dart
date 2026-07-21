import 'permission_model.dart';

class PermissionReviewItem {
  final PermissionModel permission;

  final String employeeName;
  final String employeeEmail;

  final String? scheduleName;
  final String? scheduleStartTime;
  final String? scheduleEndTime;
  final int? graceMinutes;
  final String? scheduleType;

  const PermissionReviewItem({
    required this.permission,
    required this.employeeName,
    required this.employeeEmail,
    this.scheduleName,
    this.scheduleStartTime,
    this.scheduleEndTime,
    this.graceMinutes,
    this.scheduleType,
  });
}