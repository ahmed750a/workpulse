class LeaveBalanceModel {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final int year;
  final double entitledDays;
  final double carryForwardDays;
  final double usedDays;
  final double pendingDays;
  final double remainingDays;
  final bool isEnabled;
  final String? leaveTypeName;
  final int? defaultDaysPerYear;
  const LeaveBalanceModel({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.year,
    required this.entitledDays,
    required this.carryForwardDays,
    required this.usedDays,
    required this.pendingDays,
    required this.remainingDays,
    required this.isEnabled,
    this.leaveTypeName,
    this.defaultDaysPerYear,
  });

  factory LeaveBalanceModel.fromJson(Map<String, dynamic> json) {
    final leaveType = json['leave_types'] as Map<String, dynamic>?;

    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return LeaveBalanceModel(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employee_id'] ?? '').toString(),
      leaveTypeId: (json['leave_type_id'] ?? json['leave_type_id'.toString()] ?? '').toString(),
      year: (json['year'] as num?)?.toInt() ?? 0,
      entitledDays: toDouble(json['entitled_days']),
      carryForwardDays: toDouble(json['carry_forward_days']),
      usedDays: toDouble(json['used_days']),
      pendingDays: toDouble(json['pending_days']),
      remainingDays: toDouble(json['remaining_days']),
      isEnabled: json.containsKey('is_enabled')
          ? json['is_enabled'] == true
          : true,
      leaveTypeName: json['leave_type_name']?.toString() ?? leaveType?['name']?.toString(),
      defaultDaysPerYear: (json['days_per_year'] as num?)?.toInt(),
    );
  }
}