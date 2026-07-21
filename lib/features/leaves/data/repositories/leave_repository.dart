import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_employee_item.dart';
import '../models/leave_balance_model.dart';
import '../models/leave_request_model.dart';
import '../models/leave_type_model.dart';
import '../models/leave_review_item.dart';

class LeaveRepository {
  final SupabaseClient _client;

  LeaveRepository(this._client);

  String _authUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return user.id;
  }

  Future<List<LeaveTypeModel>> getLeaveTypes() async {
    final data = await _client
        .from('leave_types')
        .select()
        .order('created_at', ascending: true);

    return data.map<LeaveTypeModel>((e) => LeaveTypeModel.fromJson(e)).toList();
  }

  Future<List<LeaveBalanceModel>> getMyLeaveBalances({required int year}) async {
    final data = await _client.rpc(
      'get_my_leave_summary',
      params: {'p_year': year},
    );

    return (data as List)
        .map<LeaveBalanceModel>((e) => LeaveBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }



  Future<List<LeaveRequestModel>> getMyLeaveRequests() async {
    final employeeId = _authUserId();

    final data = await _client
        .from('leaves')
        .select('*, leave_types(name)')
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);

    return data
        .map<LeaveRequestModel>((e) => LeaveRequestModel.fromJson(e))
        .toList();
  }
  Future<List<AdminEmployeeItem>> getEmployeesForAdmin() async {
    final data = await _client
        .from('profiles')
        .select('id, full_name, email')
        .order('created_at', ascending: false);

    return data.map<AdminEmployeeItem>((e) => AdminEmployeeItem.fromJson(e)).toList();
  }
  Future<List<AdminEmployeeItem>> searchEmployeesForAdmin({
    required String query,
    required int limit,
    required int offset,
  }) async {
    final q = query.trim();

    dynamic request = _client
        .from('profiles')
        .select('id, full_name, email');

    if (q.isNotEmpty) {
      request = request.or('full_name.ilike.%$q%,email.ilike.%$q%');
    }

    final data = await request
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    return data
        .map<AdminEmployeeItem>((e) => AdminEmployeeItem.fromJson(e))
        .toList();
  }
  Future<List<LeaveBalanceModel>> getEmployeeLeaveBalances({
    required String employeeId,
    required int year,
  }) async {
    final data = await _client.rpc(
      'admin_get_employee_leave_types_balances',
      params: {
        'p_employee_id': employeeId,
        'p_year': year,
      },
    );

    return (data as List)
        .map<LeaveBalanceModel>((e) => LeaveBalanceModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> adminSetEmployeeLeaveBalance({
    required String employeeId,
    required String leaveTypeId,
    required int year,
    required double entitledDays,
    required double carryForwardDays,
    required bool isEnabled,
  }) async {
    await _client.rpc(
      'admin_upsert_employee_leave_balance',
      params: {
        'p_employee_id': employeeId,
        'p_leave_type_id': leaveTypeId,
        'p_year': year,
        'p_entitled_days': entitledDays,
        'p_carry_forward_days': carryForwardDays,
        'p_is_enabled': isEnabled,
      },
    );
  }
  Future<void> submitLeaveRequest({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
    required String requestUnit,
    String? halfDayPart,
  }) async {
    await _client.rpc(
      'submit_leave_request',
      params: {
        'p_leave_type_id': leaveTypeId,
        'p_start_date': startDate,
        'p_end_date': endDate,
        'p_reason': reason,
        'p_request_unit': requestUnit,
        'p_half_day_part': halfDayPart,
      },
    );
  }

  Future<void> cancelLeaveRequest({
    required String leaveId,
  }) async {
    await _client.rpc(
      'cancel_leave_request',
      params: {
        'p_leave_id': leaveId,
      },
    );
  }

  Future<List<LeaveReviewItem>> getPendingLeavesForReview() async {
    final data = await _client
        .from('leaves')
        .select('''
          *,
          profiles!leaves_employee_id_fkey(
            full_name,
            email
          ),
          leave_types(
            name
          )
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return data.map<LeaveReviewItem>((item) {
      final profile = item['profiles'] as Map<String, dynamic>?;
      final leaveType = item['leave_types'] as Map<String, dynamic>?;

      return LeaveReviewItem(
        leave: LeaveRequestModel.fromJson(item),
        employeeName: profile?['full_name']?.toString() ?? 'غير معروف',
        employeeEmail: profile?['email']?.toString() ?? '',
        leaveTypeName: leaveType?['name']?.toString(),
      );
    }).toList();
  }

  Future<void> approveLeaveRequest({
    required String leaveId,
  }) async {
    await _client.rpc(
      'approve_leave_request',
      params: {
        'p_leave_id': leaveId,
      },
    );
  }

  Future<void> rejectLeaveRequest({
    required String leaveId,
    required String rejectionReason,
  }) async {
    await _client.rpc(
      'reject_leave_request',
      params: {
        'p_leave_id': leaveId,
        'p_rejection_reason': rejectionReason,
      },
    );
  }
}