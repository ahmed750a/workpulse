class AdminPermissionsReportRowModel {
  final String id;
  final String employeeId;
  final String employeeName;
  final String permissionDate;
  final String type;
  final String status;
  final int totalMinutes;
  final String reason;

  const AdminPermissionsReportRowModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.permissionDate,
    required this.type,
    required this.status,
    required this.totalMinutes,
    required this.reason,
  });

  factory AdminPermissionsReportRowModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminPermissionsReportRowModel(
      id: (json['id'] ?? '').toString(),
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? 'غير معروف').toString(),
      permissionDate: (json['permission_date'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      totalMinutes: toInt(json['total_minutes']),
      reason: (json['reason'] ?? '').toString(),
    );
  }
}