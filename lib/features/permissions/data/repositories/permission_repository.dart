import 'package:supabase_flutter/supabase_flutter.dart';
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

  // ✅ إنشاء طلب إذن جديد
  Future<PermissionModel> createPermission({
    required String employeeId,
    required String permissionDate,
    required String startTime,
    required String endTime,
    required String type,
    required String reason,
  }) async {
    // التحقق من عدم وجود طلب مكرر لنفس اليوم ونفس النوع
    final existing = await _client
        .from('permissions')
        .select()
        .eq('employee_id', employeeId)
        .eq('permission_date', permissionDate)
        .eq('type', type)
        .not('status', 'eq', 'rejected')
        .not('status', 'eq', 'cancelled')
        .maybeSingle();

    if (existing != null) {
      throw Exception('يوجد طلب إذن مسبق لهذا اليوم بنفس النوع');
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