class AdminLeaveReportRowModel {
  final String employeeId;
  final String employeeName;
  final String leaveTypeId;
  final String leaveTypeName;
  final int year;
  final double entitledDays;
  final double carryForwardDays;
  final double usedDays;
  final double pendingDays;
  final double remainingDays;
  final bool isEnabled;

  const AdminLeaveReportRowModel({
    required this.employeeId,
    required this.employeeName,
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.year,
    required this.entitledDays,
    required this.carryForwardDays,
    required this.usedDays,
    required this.pendingDays,
    required this.remainingDays,
    required this.isEnabled,
  });

  factory AdminLeaveReportRowModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0;
    }

    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminLeaveReportRowModel(
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? 'غير معروف').toString(),
      leaveTypeId: (json['leave_type_id'] ?? '').toString(),
      leaveTypeName: (json['leave_type_name'] ?? '--').toString(),
      year: toInt(json['year']),
      entitledDays: toDouble(json['entitled_days']),
      carryForwardDays: toDouble(json['carry_forward_days']),
      usedDays: toDouble(json['used_days']),
      pendingDays: toDouble(json['pending_days']),
      remainingDays: toDouble(json['remaining_days']),
      isEnabled: json['is_enabled'] == true,
    );
  }
}