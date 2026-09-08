class AdminTodaySummaryModel {
  final int totalEmployees;
  final int checkedInNow;
  final int completedToday;
  final int lateToday;
  final int onApprovedLeaveToday;

  const AdminTodaySummaryModel({
    required this.totalEmployees,
    required this.checkedInNow,
    required this.completedToday,
    required this.lateToday,
    required this.onApprovedLeaveToday,
  });

  factory AdminTodaySummaryModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) {
      if (v is num) return v.toInt();
      return int.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return AdminTodaySummaryModel(
      totalEmployees: toInt(json['total_employees']),
      checkedInNow: toInt(json['checked_in_now']),
      completedToday: toInt(json['completed_today']),
      lateToday: toInt(json['late_today']),
      onApprovedLeaveToday: toInt(json['on_approved_leave_today']),
    );
  }
}