import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/services/app_notification_dispatcher.dart';
import '../models/admin_employee_item.dart';
import '../models/carry_policy_item_model.dart';
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
  Future<Map<String, dynamic>> adminApplyCarryForward({
    required int fromYear,
    required int toYear,
  }) async {
    final data = await _client.rpc(
      'admin_apply_carry_forward',
      params: {
        'p_from_year': fromYear,
        'p_to_year': toYear,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
  Future<Map<String, dynamic>> adminPreviewCarryForward({
    required int fromYear,
    required int toYear,
  }) async {
    final data = await _client.rpc(
      'admin_preview_carry_forward',
      params: {
        'p_from_year': fromYear,
        'p_to_year': toYear,
      },
    );

    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }
  Future<void> ensureCarryPolicyYear({required int year}) async {
    await _client.from('leave_carry_policies').upsert(
      {
        'year': year,
        'is_carry_enabled': true,
      },
      onConflict: 'year',
    );
  }

  Future<List<CarryPolicyItemModel>> getCarryPolicyItemsByYear({
    required int year,
  }) async {
    await ensureCarryPolicyYear(year: year);

    final policyData = await _client
        .from('leave_carry_policies')
        .select('id')
        .eq('year', year)
        .single();

    final policyId = policyData['id'].toString();

    final leaveTypes = await _client
        .from('leave_types')
        .select('id, name, carry_forward_enabled, carry_forward_max_days')
        .order('created_at', ascending: true);

    final items = await _client
        .from('leave_carry_policy_items')
        .select('leave_type_id, is_enabled, max_days')
        .eq('policy_id', policyId);

    final itemMap = <String, Map<String, dynamic>>{};
    for (final row in items) {
      itemMap[row['leave_type_id'].toString()] = Map<String, dynamic>.from(row);
    }

    double asDouble(dynamic v) {
      if (v is num) return v.toDouble();
      return double.tryParse(v?.toString() ?? '0') ?? 0;
    }

    return leaveTypes.map<CarryPolicyItemModel>((lt) {
      final leaveType = Map<String, dynamic>.from(lt);
      final id = leaveType['id'].toString();
      final row = itemMap[id];

      return CarryPolicyItemModel(
        leaveTypeId: id,
        leaveTypeName: (leaveType['name'] ?? '--').toString(),
        isEnabled: row == null
            ? (leaveType['carry_forward_enabled'] == true)
            : (row['is_enabled'] == true),
        maxDays: row == null
            ? asDouble(leaveType['carry_forward_max_days'])
            : asDouble(row['max_days']),
      );
    }).toList();
  }

  Future<void> upsertCarryPolicyItem({
    required int year,
    required String leaveTypeId,
    required bool isEnabled,
    required double maxDays,
  }) async {
    await ensureCarryPolicyYear(year: year);

    final policyData = await _client
        .from('leave_carry_policies')
        .select('id')
        .eq('year', year)
        .single();

    final policyId = policyData['id'].toString();

    await _client.from('leave_carry_policy_items').upsert(
      {
        'policy_id': policyId,
        'leave_type_id': leaveTypeId,
        'is_enabled': isEnabled,
        'max_days': isEnabled ? maxDays : 0,
      },
      onConflict: 'policy_id,leave_type_id',
    );
  }
  Future<int> adminBootstrapLeaveBalancesForYear({
    required int year,
  }) async {
    final data = await _client.rpc(
      'admin_bootstrap_leave_balances_for_year',
      params: {
        'p_year': year,
      },
    );

    if (data is Map<String, dynamic>) {
      return (data['inserted_count'] as num?)?.toInt() ?? 0;
    }

    if (data is Map) {
      return (data['inserted_count'] as num?)?.toInt() ?? 0;
    }

    return 0;
  }
  Future<Map<String, int>> adminPrepareLeaveBalancesForYear({
    required int year,
  }) async {
    final data = await _client.rpc(
      'admin_prepare_leave_balances_for_year',
      params: {'p_year': year},
    );

    final map = (data as Map);
    return {
      'insertedCount': (map['inserted_count'] as num?)?.toInt() ?? 0,
      'enabledCount': (map['enabled_count'] as num?)?.toInt() ?? 0,
    };
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
    final employeeId = _authUserId();

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

    final profile = await _client
        .from('profiles')
        .select('full_name')
        .eq('id', employeeId)
        .maybeSingle();

    final employeeName = profile?['full_name']?.toString() ?? 'موظف';

    try {
      await AppNotificationDispatcher.instance.notifyAdmins(
        client: _client,
        senderId: employeeId,
        title: 'طلب إجازة جديد',
        body: '$employeeName أرسل طلب إجازة جديد بانتظار المراجعة.',
        kind: 'leave_request',
      );
    } catch (_) {}
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
    final adminId = _authUserId();

    final row = await _client
        .from('leaves')
        .select('employee_id')
        .eq('id', leaveId)
        .maybeSingle();

    await _client.rpc(
      'approve_leave_request',
      params: {
        'p_leave_id': leaveId,
      },
    );

    final employeeId = row?['employee_id']?.toString();
    if (employeeId != null) {
      try {
        await AppNotificationDispatcher.instance.notifyEmployee(
          client: _client,
          recipientId: employeeId,
          senderId: adminId,
          title: 'تم قبول طلب الإجازة',
          body: 'تمت الموافقة على طلب الإجازة الخاص بك.',
          kind: 'leave_approved',
          payload: {'leave_id': leaveId},
        );
      } catch (_) {}
    }
  }

  Future<void> rejectLeaveRequest({
    required String leaveId,
    required String rejectionReason,
  }) async {
    final adminId = _authUserId();

    final row = await _client
        .from('leaves')
        .select('employee_id')
        .eq('id', leaveId)
        .maybeSingle();

    await _client.rpc(
      'reject_leave_request',
      params: {
        'p_leave_id': leaveId,
        'p_rejection_reason': rejectionReason,
      },
    );

    final employeeId = row?['employee_id']?.toString();
    if (employeeId != null) {
      try {
        await AppNotificationDispatcher.instance.notifyEmployee(
          client: _client,
          recipientId: employeeId,
          senderId: adminId,
          title: 'تم رفض طلب الإجازة',
          body: 'تم رفض طلب الإجازة الخاص بك.',
          kind: 'leave_rejected',
          payload: {'leave_id': leaveId},
        );
      } catch (_) {}
    }
  }
}