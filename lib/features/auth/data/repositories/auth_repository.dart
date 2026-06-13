import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
class AuthRepository {
  final SupabaseClient _client;
  AuthRepository(this._client);

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    // تسجيل الدخول في Supabase Auth
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = res.user;

    if (user == null) return null;

    if (user.emailConfirmedAt == null) {
      throw Exception('يرجى تأكيد بريدك الإلكتروني قبل تسجيل الدخول.');
    }

// جلب بيانات الملف الشخصي من جدول profiles
    final profileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse == null) {
      throw Exception('الحساب غير موجود.');
    }

    final data = profileResponse;

    if (data['is_active'] != true) {
      throw Exception('الحساب غير مفعل. الرجاء الانتظار لتفعيل الإدارة.');
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: data['full_name'],
      role: data['role'],
      createdAt: data['created_at'],
    );
  }
  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String activationCode,
  }) async {
    await _client.functions.invoke(
      'clever-responder',
      body: {
        'full_name': fullName,
        'email': email,
        'password': password,
        'activation_code': activationCode,
      },
    );
  }
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;
  Future<UserModel?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;

    if (user == null) return null;

    final profileResponse = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profileResponse == null) return null;

    if (profileResponse['is_active'] != true) {
      await _client.auth.signOut();
      throw Exception('الحساب غير مفعل. الرجاء الانتظار لتفعيل الإدارة.');
    }

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: profileResponse['full_name'],
      role: profileResponse['role'],
      createdAt: profileResponse['created_at'],
    );
  }

}
