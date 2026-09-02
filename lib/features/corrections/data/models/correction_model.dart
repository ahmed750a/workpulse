class CorrectionModel {
  final String id;
  final String employeeId;
  final String? attendanceRecordId;
  final String correctionDate; // yyyy-mm-dd
  final String type; // check_in | check_out
  final String requestedTime; // HH:mm:ss
  final String reason;
  final String status; // pending | approved | rejected
  final String? reviewedBy;
  final String? reviewedAt;
  final String? rejectionReason;
  final String? createdAt;
  final String? updatedAt;

  const CorrectionModel({
    required this.id,
    required this.employeeId,
    required this.attendanceRecordId,
    required this.correctionDate,
    required this.type,
    required this.requestedTime,
    required this.reason,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory CorrectionModel.fromJson(Map<String, dynamic> json) {
    return CorrectionModel(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employee_id'] ?? '').toString(),
      attendanceRecordId: json['attendance_record_id']?.toString(),
      correctionDate: (json['correction_date'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      requestedTime: (json['requested_time'] ?? '').toString(),
      reason: (json['reason'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reviewedBy: json['reviewed_by']?.toString(),
      reviewedAt: json['reviewed_at']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}