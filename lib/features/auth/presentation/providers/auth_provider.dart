import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/supabase_provider.dart';
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
  late final AuthRepository _repository;

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
    await _repository.signOut();
    state = const AuthState();
  }
  Future<void> restoreSession() async {
    try {
      final user = await _repository.getCurrentUserProfile();

      if (user != null) {
        state = AuthState(user: user);
      }
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);