class AdminGeofenceReportRowModel {
  final String employeeId;
  final String employeeName;
  final String attendanceDate;
  final String status;
  final bool geofenceEnabled;
  final double? distanceMeters;
  final int geofenceRadiusM;
  final bool isOutside;
  final String? locationUpdatedAt;

  const AdminGeofenceReportRowModel({
    required this.employeeId,
    required this.employeeName,
    required this.attendanceDate,
    required this.status,
    required this.geofenceEnabled,
    required this.distanceMeters,
    required this.geofenceRadiusM,
    required this.isOutside,
    required this.locationUpdatedAt,
  });

  factory AdminGeofenceReportRowModel.fromJson(Map<String, dynamic> json) {
    double? toDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminGeofenceReportRowModel(
      employeeId: (json['employee_id'] ?? '').toString(),
      employeeName: (json['employee_name'] ?? 'غير معروف').toString(),
      attendanceDate: (json['attendance_date'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      geofenceEnabled: json['geofence_enabled'] == true,
      distanceMeters: toDouble(json['distance_meters']),
      geofenceRadiusM: toInt(json['geofence_radius_m']),
      isOutside: json['is_outside'] == true,
      locationUpdatedAt: json['location_updated_at']?.toString(),
    );
  }
}