class LeaveRequestModel {
  final String id;
  final String employeeId;
  final String leaveTypeId;
  final String startDate;
  final String endDate;
  final double totalDays;
  final String? reason;
  final String status;
  final String? reviewedBy;
  final String? reviewedAt;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;
  final String? leaveTypeName;
  final String requestUnit;
  final String? halfDayPart;

  const LeaveRequestModel({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.leaveTypeName,
    required this.requestUnit,
    this.halfDayPart,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    final leaveType = json['leave_types'] as Map<String, dynamic>?;

    double toDouble(dynamic value) {
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return LeaveRequestModel(
      id: json['id'].toString(),
      employeeId: json['employee_id'].toString(),
      leaveTypeId: json['leave_type_id'].toString(),
      startDate: json['start_date'].toString(),
      endDate: json['end_date'].toString(),
      totalDays: toDouble(json['total_days']),
      reason: json['reason']?.toString(),
      status: json['status'].toString(),
      reviewedBy: json['reviewed_by']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      leaveTypeName: leaveType?['name']?.toString(),
      requestUnit: json['request_unit']?.toString() ?? 'full_day',
      halfDayPart: json['half_day_part']?.toString(),
    );
  }
}