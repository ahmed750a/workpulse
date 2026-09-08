class AdminCorrectionReportRowModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String correctionDate;
  final String type; // check_in | check_out
  final String requestedTime;
  final String status; // pending | approved | rejected
  final String reason;
  final String? rejectionReason;

  const AdminCorrectionReportRowModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.correctionDate,
    required this.type,
    required this.requestedTime,
    required this.status,
    required this.reason,
    required this.rejectionReason,
  });

  factory AdminCorrectionReportRowModel.fromJson(Map<String, dynamic> json) {
    return AdminCorrectionReportRowModel(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? 'غير معروف').toString(),
      correctionDate: (json['correction_date'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      requestedTime: (json['requested_time'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }
}