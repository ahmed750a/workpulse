import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/permission_review_item.dart';
import '../models/permission_model.dart';
class PermissionRepository {
  final SupabaseClient _client;

  PermissionRepository(this._client);

  // ✅ جلب أذونات الموظف
  Future<List<PermissionModel>> getMyPermissions(String employeeId) async {
    final data = await _client
        .from('permissions')
        .select()
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);

    return data
        .map<PermissionModel>((item) => PermissionModel.fromJson(item))
        .toList();
  }
  Future<List<PermissionReviewItem>> getPendingPermissionsForReview() async {
    final rows = await _client
        .from('permissions')
        .select('''
        *,
        profiles!permissions_employee_id_fkey(
          full_name,
          email,
          work_schedule_id,
          work_schedules(
            name,
            start_time,
            end_time,
            grace_minutes,
            schedule_type
          )
        )
      ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return rows.map<PermissionReviewItem>((item) {
      final profile = item['profiles'] as Map<String, dynamic>?;
      final schedule = profile?['work_schedules'] as Map<String, dynamic>?;

      return PermissionReviewItem(
        permission: PermissionModel.fromJson(item),
        employeeName: profile?['full_name']?.toString() ?? 'غير معروف',
        employeeEmail: profile?['email']?.toString() ?? '',
        scheduleName: schedule?['name']?.toString(),
        scheduleStartTime: schedule?['start_time']?.toString(),
        scheduleEndTime: schedule?['end_time']?.toString(),
        graceMinutes: schedule?['grace_minutes'] is num
            ? (schedule?['grace_minutes'] as num).toInt()
            : null,
        scheduleType: schedule?['schedule_type']?.toString(),
      );
    }).toList();
  }
  // ✅ إنشاء طلب إذن جديد
// ✅ إنشاء طلب إذن جديد
  Future<PermissionModel> createPermission({
    required String employeeId,
    required String permissionDate,
    required String startTime,
    required String endTime,
    required String type,
    required String reason,
  }) async {
    // 1) منع طلب pending مكرر
    final existingPending = await _client
        .from('permissions')
        .select('id')
        .eq('employee_id', employeeId)
        .eq('permission_date', permissionDate)
        .eq('type', type)
        .eq('status', 'pending')
        .maybeSingle();

    if (existingPending != null) {
      throw Exception('يوجد طلب لنفس النوع في هذا اليوم وهو قيد المراجعة.');
    }

    // 2) منع طلب approved مكرر
    final existingApproved = await _client
        .from('permissions')
        .select('id')
        .eq('employee_id', employeeId)
        .eq('permission_date', permissionDate)
        .eq('type', type)
        .eq('status', 'approved')
        .maybeSingle();

    if (existingApproved != null) {
      throw Exception('يوجد طلب معتمد مسبقا لنفس النوع في هذا اليوم.');
    }

    final data = await _client
        .from('permissions')
        .insert({
      'employee_id': employeeId,
      'permission_date': permissionDate,
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
      'reason': reason,
      'status': 'pending',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .select()
        .single();

    return PermissionModel.fromJson(data);
  }

  // ✅ إلغاء طلب إذن
  Future<void> cancelPermission(String permissionId) async {
    await _client
        .from('permissions')
        .update({
      'status': 'cancelled',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', permissionId);
  }

  // ✅ للمدير: جلب كل الطلبات المعلقة
  Future<List<PermissionModel>> getPendingPermissions() async {
    final data = await _client
        .from('permissions')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return data
        .map<PermissionModel>((item) => PermissionModel.fromJson(item))
        .toList();
  }

  // ✅ للمدير: الموافقة على طلب
  Future<void> approvePermission({
    required String permissionId,
    required String reviewedBy,
  }) async {
    await _client
        .from('permissions')
        .update({
      'status': 'approved',
      'reviewed_by': reviewedBy,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', permissionId);
  }

  // ✅ للمدير: رفض طلب
  Future<void> rejectPermission({
    required String permissionId,
    required String reviewedBy,
    required String rejectionReason,
  }) async {
    await _client
        .from('permissions')
        .update({
      'status': 'rejected',
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
      'reviewed_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', permissionId);
  }

  // ✅ التحقق من وجود إذن معتمد لوقت معين
  Future<PermissionModel?> getApprovedPermissionForDate({
    required String employeeId,
    required String date,
    required String type,
  }) async {
    final data = await _client
        .from('permissions')
        .select()
        .eq('employee_id', employeeId)
        .eq('permission_date', date)
        .eq('type', type)
        .eq('status', 'approved')
        .maybeSingle();

    if (data == null) return null;
    return PermissionModel.fromJson(data);
  }
}