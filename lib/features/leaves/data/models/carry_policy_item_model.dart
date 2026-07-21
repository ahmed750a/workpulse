class CarryPolicyItemModel {
  final String leaveTypeId;
  final String leaveTypeName;
  final bool isEnabled;
  final double maxDays;

  const CarryPolicyItemModel({
    required this.leaveTypeId,
    required this.leaveTypeName,
    required this.isEnabled,
    required this.maxDays,
  });

  CarryPolicyItemModel copyWith({
    bool? isEnabled,
    double? maxDays,
  }) {
    return CarryPolicyItemModel(
      leaveTypeId: leaveTypeId,
      leaveTypeName: leaveTypeName,
      isEnabled: isEnabled ?? this.isEnabled,
      maxDays: maxDays ?? this.maxDays,
    );
  }
}