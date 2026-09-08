class AdminTodayViolationModel {
  final String employeeId;
  final String employeeName;
  final String attendanceDate;
  final String status;
  final int unapprovedLateMinutes;
  final int unapprovedEarlyLeaveMinutes;
  final int workedMinutes;

  const AdminTodayViolationModel({
    required this.employeeId,
    required this.employeeName,
    required this.attendanceDate,
    required this.status,
    required this.unapprovedLateMinutes,
    required this.unapprovedEarlyLeaveMinutes,
    required this.workedMinutes,
  });

  factory AdminTodayViolationModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminTodayViolationModel(
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? '').toString(),
      attendanceDate: (json['attendance_date'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      unapprovedLateMinutes: toInt(json['unapproved_late_minutes']),
      unapprovedEarlyLeaveMinutes: toInt(json['unapproved_early_leave_minutes']),
      workedMinutes: toInt(json['worked_minutes']),
    );
  }
}