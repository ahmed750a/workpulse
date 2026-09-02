import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/correction_model.dart';
import '../../data/repositories/correction_repository.dart';

final correctionRepositoryProvider = Provider<CorrectionRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return CorrectionRepository(client);
});

class CorrectionsState {
  final List<CorrectionModel> myCorrections;
  final List<Map<String, dynamic>> pendingCorrections;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;

  const CorrectionsState({
    this.myCorrections = const [],
    this.pendingCorrections = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
  });

  CorrectionsState copyWith({
    List<CorrectionModel>? myCorrections,
    List<Map<String, dynamic>>? pendingCorrections,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
  }) {
    return CorrectionsState(
      myCorrections: myCorrections ?? this.myCorrections,
      pendingCorrections: pendingCorrections ?? this.pendingCorrections,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class CorrectionsNotifier extends Notifier<CorrectionsState> {
  late final CorrectionRepository _repository;

  @override
  CorrectionsState build() {
    _repository = ref.read(correctionRepositoryProvider);
    ref.watch(sessionVersionProvider);
    return const CorrectionsState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

  Future<void> loadMyCorrections() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getMyCorrections();
      state = state.copyWith(myCorrections: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createCorrection({
    required String correctionDate,
    required String type,
    required String requestedTime,
    required String reason,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      await _repository.createCorrection(
        correctionDate: correctionDate,
        type: type,
        requestedTime: requestedTime,
        reason: reason,
      );
      await loadMyCorrections();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }

  Future<void> loadPendingForAdmin() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repository.getPendingCorrectionsForAdmin();
      state = state.copyWith(pendingCorrections: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> approveCorrection(String correctionId) async {
    final reviewerId = _currentUserId;
    if (reviewerId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.approveCorrection(
        correctionId: correctionId,
        reviewedBy: reviewerId,
      );
      await loadPendingForAdmin();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> rejectCorrection({
    required String correctionId,
    required String rejectionReason,
  }) async {
    final reviewerId = _currentUserId;
    if (reviewerId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.rejectCorrection(
        correctionId: correctionId,
        reviewedBy: reviewerId,
        rejectionReason: rejectionReason,
      );
      await loadPendingForAdmin();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final correctionsProvider =
NotifierProvider<CorrectionsNotifier, CorrectionsState>(
  CorrectionsNotifier.new,
);