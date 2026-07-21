import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/providers/supabase_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';
import '../../data/models/permission_review_item.dart';
final permissionRepositoryProvider = Provider<PermissionRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return PermissionRepository(client);
});

class PermissionsState {
  final List<PermissionModel> permissions;
  final List<PermissionModel> pendingPermissions;
  final List<PermissionReviewItem> pendingReviewItems;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  const PermissionsState({
    this.permissions = const [],
    this.pendingPermissions = const [],
    this.pendingReviewItems = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  PermissionsState copyWith({
    List<PermissionModel>? permissions,
    List<PermissionModel>? pendingPermissions,
    List<PermissionReviewItem>? pendingReviewItems,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isSubmitting,
  }) {
    return PermissionsState(
      permissions: permissions ?? this.permissions,
      pendingPermissions: pendingPermissions ?? this.pendingPermissions,
      pendingReviewItems: pendingReviewItems ?? this.pendingReviewItems,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class PermissionsNotifier extends Notifier<PermissionsState> {
  late final PermissionRepository _repository;

  @override
  PermissionsState build() {
    _repository = ref.read(permissionRepositoryProvider);
    ref.watch(sessionVersionProvider); // ✅
    return const PermissionsState();
  }

  String? get _currentUserId => ref.read(authProvider).user?.id;

  // ✅ جلب أذونات الموظف
  Future<void> loadMyPermissions() async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final permissions = await _repository.getMyPermissions(userId);
      state = state.copyWith(
        permissions: permissions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // ✅ إنشاء طلب إذن
  Future<bool> createPermission({
    required String permissionDate,
    required String startTime,
    required String endTime,
    required String type,
    required String reason,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.createPermission(
        employeeId: userId,
        permissionDate: permissionDate,
        startTime: startTime,
        endTime: endTime,
        type: type,
        reason: reason,
      );

      await loadMyPermissions();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isSubmitting: false,
      );
      return false;
    }
  }

  // ✅ إلغاء طلب إذن
  Future<void> cancelPermission(String permissionId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.cancelPermission(permissionId);
      await loadMyPermissions();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> loadPendingPermissionsForReview() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final items = await _repository.getPendingPermissionsForReview();
      state = state.copyWith(
        pendingReviewItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  // ✅ للمدير: جلب الطلبات المعلقة
  Future<void> loadPendingPermissions() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final pending = await _repository.getPendingPermissions();
      state = state.copyWith(
        pendingPermissions: pending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // ✅ للمدير: الموافقة
  Future<void> approvePermission(String permissionId) async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.approvePermission(
        permissionId: permissionId,
        reviewedBy: userId,
      );
      await loadPendingPermissionsForReview();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  // ✅ للمدير: الرفض
  Future<void> rejectPermission({
    required String permissionId,
    required String rejectionReason,
  }) async {
    final userId = _currentUserId;
    if (userId == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.rejectPermission(
        permissionId: permissionId,
        reviewedBy: userId,
        rejectionReason: rejectionReason,
      );
      await loadPendingPermissionsForReview();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
}

final permissionsProvider =
NotifierProvider<PermissionsNotifier, PermissionsState>(
  PermissionsNotifier.new,
);