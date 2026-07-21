import 'leave_request_model.dart';

class LeaveReviewItem {
  final LeaveRequestModel leave;
  final String employeeName;
  final String employeeEmail;
  final String? leaveTypeName;

  const LeaveReviewItem({
    required this.leave,
    required this.employeeName,
    required this.employeeEmail,
    this.leaveTypeName,
  });
}