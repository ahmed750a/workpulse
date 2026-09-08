class AdminTodayWorkHoursModel {
  final String employeeId;
  final String employeeName;
  final String attendanceDate;
  final String status;
  final String scheduleType;
  final int requiredMinutes;
  final int workedMinutes;
  final int overtimeMinutes;
  final int remainingMinutes;

  const AdminTodayWorkHoursModel({
    required this.employeeId,
    required this.employeeName,
    required this.attendanceDate,
    required this.status,
    required this.scheduleType,
    required this.requiredMinutes,
    required this.workedMinutes,
    required this.overtimeMinutes,
    required this.remainingMinutes,
  });

  factory AdminTodayWorkHoursModel.fromJoinedRow(Map<String, dynamic> row) {
    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    final profile = row['profiles'] as Map<String, dynamic>?;
    final schedule = profile?['work_schedules'] as Map<String, dynamic>?;

    final required = toInt(schedule?['required_minutes']);
    final worked = toInt(row['worked_minutes']);
    final overtime = worked > required ? worked - required : 0;
    final remaining = required > worked ? required - worked : 0;

    return AdminTodayWorkHoursModel(
      employeeId: row['employee_id']?.toString() ?? '',
      employeeName: profile?['full_name']?.toString() ?? 'غير معروف',
      attendanceDate: (row['attendance_date'] ?? '').toString(),
      status: row['status']?.toString() ?? '--',
      scheduleType: schedule?['schedule_type']?.toString() ?? 'fixed',
      requiredMinutes: required,
      workedMinutes: worked,
      overtimeMinutes: overtime,
      remainingMinutes: remaining,
    );
  }
}