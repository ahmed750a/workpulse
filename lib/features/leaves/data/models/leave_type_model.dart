class LeaveTypeModel {
  final String id;
  final String name;
  final int daysPerYear;
  final bool requiresApproval;
  final bool isPaid;

  const LeaveTypeModel({
    required this.id,
    required this.name,
    required this.daysPerYear,
    required this.requiresApproval,
    required this.isPaid,
  });

  factory LeaveTypeModel.fromJson(Map<String, dynamic> json) {
    return LeaveTypeModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      daysPerYear: (json['days_per_year'] as num?)?.toInt() ?? 0,
      requiresApproval: json['requires_approval'] == true,
      isPaid: json['is_paid'] == true,
    );
  }
}