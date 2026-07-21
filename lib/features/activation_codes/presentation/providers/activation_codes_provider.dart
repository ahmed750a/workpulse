import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../../data/models/activation_code_model.dart';
import '../../data/repositories/activation_code_repository.dart';

final activationCodeRepositoryProvider =
Provider<ActivationCodeRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return ActivationCodeRepository(client);
});

class ActivationCodesState {
  final List<ActivationCodeModel> codes;
  final bool isLoading;
  final String? error;
  final String? generatedCode;

  const ActivationCodesState({
    this.codes = const [],
    this.isLoading = false,
    this.error,
    this.generatedCode,
  });

  ActivationCodesState copyWith({
    List<ActivationCodeModel>? codes,
    bool? isLoading,
    String? error,
    bool clearError = false,           // ✅
    String? generatedCode,
    bool clearGeneratedCode = false,
  }) {
    return ActivationCodesState(
      codes: codes ?? this.codes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,  // ✅
      generatedCode: clearGeneratedCode ? null : generatedCode ?? this.generatedCode,
    );
  }
}

class ActivationCodesNotifier extends Notifier<ActivationCodesState> {
  late final ActivationCodeRepository _repository;

  @override
  ActivationCodesState build() {
    _repository = ref.read(activationCodeRepositoryProvider);
    ref.watch(sessionVersionProvider); // ✅ يربط بعمر الجلسة
    return const ActivationCodesState();
  }

  Future<void> loadCodes() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final codes = await _repository.getAllCodes();
      state = state.copyWith(
        codes: codes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> deleteCode(String id) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
    );

    try {
      await _repository.deleteCode(id);
      final codes = await _repository.getAllCodes();

      state = state.copyWith(
        codes: codes,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> generateCode({
    required String fullName,
    required String email,
    String role = 'employee',
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      generatedCode: null,
    );

    try {
      final code = await _repository.generateCode(
        fullName: fullName,
        email: email,
        role: role,
      );

      final codes = await _repository.getAllCodes();

      state = state.copyWith(
        codes: codes,
        generatedCode: code,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

final activationCodesProvider =
NotifierProvider<ActivationCodesNotifier, ActivationCodesState>(
  ActivationCodesNotifier.new,
);