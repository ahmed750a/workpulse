class AdminLeaveMonthlyReportRowModel {
  final String leaveId;
  final String employeeId;
  final String employeeName;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final double totalDays;
  final String status;
  final String? reason;

  const AdminLeaveMonthlyReportRowModel({
    required this.leaveId,
    required this.employeeId,
    required this.employeeName,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    required this.reason,
  });

  factory AdminLeaveMonthlyReportRowModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminLeaveMonthlyReportRowModel(
      leaveId: (json['id'] ?? '').toString(),
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? 'غير معروف').toString(),
      leaveTypeName: (json['leave_type_name'] ?? '--').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      totalDays: toDouble(json['total_days']),
      status: (json['status'] ?? '').toString(),
      reason: json['reason']?.toString(),
    );
  }
}