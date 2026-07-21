class AdminEmployeeItem {
  final String id;
  final String fullName;
  final String email;

  const AdminEmployeeItem({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory AdminEmployeeItem.fromJson(Map<String, dynamic> json) {
    return AdminEmployeeItem(
      id: json['id'].toString(),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
    );
  }
}