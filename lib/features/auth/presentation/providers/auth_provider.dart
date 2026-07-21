import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../app/providers/supabase_provider.dart';
import '../../../../../core/services/work_timer_service.dart';
import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return AuthRepository(client);
});

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.read(authRepositoryProvider);
    return const AuthState();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      final user = await _repository.signIn(
        email: email,
        password: password,
      );

      state = AuthState(user: user);

      if (user != null) {
        await WorkTimerService.instance.restoreIfActive(userId: user.id);
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String activationCode,
  }) async {
    state = const AuthState(isLoading: true);

    try {
      await _repository.register(
        fullName: fullName,
        email: email,
        password: password,
        activationCode: activationCode,
      );

      state = const AuthState();
    } catch (e) {
      state = AuthState(error: e.toString());
      rethrow;
    }
  }

  Future<void> signOut() async {
    final currentUserId = state.user?.id;

    // نفرغ الحالة مباشرة حتى ما يظل المستخدم داخل الواجهة
    state = const AuthState();

    // نعمل reset للـ providers المرتبطة بالجلسة
    ref.read(sessionVersionProvider.notifier).increment();

    try {
      if (currentUserId != null) {
        await WorkTimerService.instance.stop(userId: currentUserId);
      }
    } catch (_) {}

    try {
      await WorkTimerService.instance.reset();
    } catch (_) {}

    try {
      await _repository.signOut();
    } catch (_) {}
  }

  Future<void> restoreSession() async {
    try {
      final user = await _repository.getCurrentUserProfile();

      if (user != null) {
        state = AuthState(user: user);
        await WorkTimerService.instance.restoreIfActive(userId: user.id);
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);