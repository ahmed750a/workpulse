import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/activation_code_model.dart';

class ActivationCodeRepository {
  final SupabaseClient _client;

  ActivationCodeRepository(this._client);

  Future<List<ActivationCodeModel>> getAllCodes() async {
    final data = await _client
        .from('activation_codes')
        .select()
        .order('created_at', ascending: false);

    return data
        .map<ActivationCodeModel>(
          (item) => ActivationCodeModel.fromJson(item),
    )
        .toList();
  }

  Future<String> generateCode({
    required String fullName,
    required String email,
    String role = 'employee',
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(normalizedEmail)) {
      throw Exception('البريد الإلكتروني غير صالح');
    }

    final existingProfile = await _client
        .from('profiles')
        .select('id')
        .eq('email', normalizedEmail)
        .maybeSingle();

    if (existingProfile != null) {
      throw Exception('يوجد حساب مسجل مسبقاً بهذا البريد الإلكتروني');
    }

    final existingCode = await _client
        .from('activation_codes')
        .select('id')
        .eq('email', normalizedEmail)
        .eq('is_used', false)
        .maybeSingle();

    if (existingCode != null) {
      throw Exception('يوجد كود تفعيل غير مستخدم لهذا البريد مسبقاً');
    }

    final random = Random();

    final code = 'WP-${100000 + random.nextInt(900000)}';
    await _client.from('activation_codes').insert({
      'code': code,
      'full_name': fullName,
      'email': normalizedEmail,
      'role': role,
      'is_used': false,
      'expires_at': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
    });

    return code;
  }

  Future<void> deleteCode(String id) async {
    await _client
        .from('activation_codes')
        .delete()
        .eq('id', id);
  }

  Future<void> markCodeAsUsed(String code) async {
    await _client
        .from('activation_codes')
        .update({'is_used': true})
        .eq('code', code);
  }
}