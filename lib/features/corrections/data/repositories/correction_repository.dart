import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/correction_model.dart';

class CorrectionRepository {
  final SupabaseClient _client;

  CorrectionRepository(this._client);

  String _authUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return user.id;
  }

  Future<List<CorrectionModel>> getMyCorrections() async {
    final employeeId = _authUserId();

    final data = await _client
        .from('corrections')
        .select()
        .eq('employee_id', employeeId)
        .order('created_at', ascending: false);

    return data.map<CorrectionModel>((e) => CorrectionModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getPendingCorrectionsForAdmin() async {
    final data = await _client
        .from('corrections')
        .select('''
          *,
          profiles!corrections_employee_id_fkey(
            full_name,
            email
          )
        ''')
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return data.map<Map<String, dynamic>>((item) {
      final profile = item['profiles'] as Map<String, dynamic>?;

      return {
        'correction': CorrectionModel.fromJson(item),
        'employeeName': profile?['full_name']?.toString() ?? 'غير معروف',
        'employeeEmail': profile?['email']?.toString() ?? '',
      };
    }).toList();
  }

  Future<void> createCorrection({
    required String correctionDate,
    required String type, // check_in | check_out
    required String requestedTime, // HH:mm:ss
    required String reason,
  }) async {
    final employeeId = _authUserId();

    final normalizedType = type.trim();
    if (normalizedType != 'check_in' && normalizedType != 'check_out') {
      throw Exception('نوع التصحيح غير صالح');
    }

    final cleanReason = reason.trim();
    if (cleanReason.length < 5) {
      throw Exception('سبب التعديل قصير جداً');
    }

    // منع تكرار pending لنفس اليوم + النوع
    final duplicate = await _client
        .from('corrections')
        .select('id')
        .eq('employee_id', employeeId)
        .eq('correction_date', correctionDate)
        .eq('type', normalizedType)
        .eq('status', 'pending')
        .maybeSingle();

    if (duplicate != null) {
      throw Exception('يوجد طلب تعديل معلق لنفس اليوم ونفس النوع');
    }

    await _client.from('corrections').insert({
      'employee_id': employeeId,
      'correction_date': correctionDate,
      'type': normalizedType,
      'requested_time': requestedTime,
      'reason': cleanReason,
      'status': 'pending',
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> approveCorrection({
    required String correctionId,
    required String reviewedBy,
  }) async {
    await _client.rpc(
      'admin_approve_correction_request',
      params: {
        'p_correction_id': correctionId,
      },
    );
  }

  Future<void> rejectCorrection({
    required String correctionId,
    required String reviewedBy,
    required String rejectionReason,
  }) async {
    await _client.rpc(
      'admin_reject_correction_request',
      params: {
        'p_correction_id': correctionId,
        'p_rejection_reason': rejectionReason.trim(),
      },
    );
  }
}