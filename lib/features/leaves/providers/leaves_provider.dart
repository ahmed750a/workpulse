import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../data/models/admin_employee_item.dart';
import '../data/models/carry_policy_item_model.dart';
import '../data/models/leave_balance_model.dart';
import '../data/models/leave_request_model.dart';
import '../data/models/leave_review_item.dart';
import '../data/models/leave_type_model.dart';
import '../data/repositories/leave_repository.dart';

final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return LeaveRepository(client);
});

class LeavesState {
  final List<LeaveTypeModel> leaveTypes;
  final List<LeaveBalanceModel> balances;
  final List<LeaveRequestModel> myRequests;
  final List<LeaveReviewItem> pendingReviewItems;
  final List<AdminEmployeeItem> adminEmployees;
  final List<LeaveBalanceModel> adminEmployeeBalances;
  final bool isLoading;
  final bool isSubmitting;
  final bool isBootstrapping;
  final bool isApplyingCarryForward;
  final String? error;
  final String adminSearchQuery;
  final int adminEmployeesOffset;
  final bool adminHasMoreEmployees;
  final bool isPreviewingCarryForward;
  final List<CarryPolicyItemModel> carryPolicyItems;
  final Map<String, dynamic>? carryPreviewResult;
  final bool isLoadingCarryPolicy;
  final bool isSavingCarryPolicy;
  const LeavesState({
    this.leaveTypes = const [],
    this.balances = const [],
    this.myRequests = const [],
    this.pendingReviewItems = const [],
    this.adminEmployees = const [],
    this.adminEmployeeBalances = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isBootstrapping = false,
    this.isApplyingCarryForward = false,
    this.error,
    this.adminSearchQuery = '',
    this.adminEmployeesOffset = 0,
    this.adminHasMoreEmployees = true,
    this.isPreviewingCarryForward = false,
    this.carryPolicyItems = const [],
    this.carryPreviewResult,
    this.isLoadingCarryPolicy = false,
    this.isSavingCarryPolicy = false,
  });

  LeavesState copyWith({
    List<LeaveTypeModel>? leaveTypes,
    List<LeaveBalanceModel>? balances,
    List<LeaveRequestModel>? myRequests,
    List<LeaveReviewItem>? pendingReviewItems,
    List<AdminEmployeeItem>? adminEmployees,
    List<LeaveBalanceModel>? adminEmployeeBalances,
    bool? isLoading,
    bool? isSubmitting,
    bool? isBootstrapping,
    bool? isApplyingCarryForward,
    String? error,
    bool clearError = false,
    String? adminSearchQuery,
    int? adminEmployeesOffset,
    bool? adminHasMoreEmployees,
    bool? isPreviewingCarryForward,
    List<CarryPolicyItemModel>? carryPolicyItems,
    Map<String, dynamic>? carryPreviewResult,
    bool? isLoadingCarryPolicy,
    bool? isSavingCarryPolicy,
    bool clearCarryPreview = false,
  }) {
    return LeavesState(
      leaveTypes: leaveTypes ?? this.leaveTypes,
      balances: balances ?? this.balances,
      myRequests: myRequests ?? this.myRequests,
      pendingReviewItems: pendingReviewItems ?? this.pendingReviewItems,
      adminEmployees: adminEmployees ?? this.adminEmployees,
      adminEmployeeBalances: adminEmployeeBalances ?? this.adminEmployeeBalances,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      isApplyingCarryForward:
      isApplyingCarryForward ?? this.isApplyingCarryForward,
      error: clearError ? null : error ?? this.error,
      adminSearchQuery: adminSearchQuery ?? this.adminSearchQuery,
      adminEmployeesOffset: adminEmployeesOffset ?? this.adminEmployeesOffset,
      adminHasMoreEmployees: adminHasMoreEmployees ?? this.adminHasMoreEmployees,
      isPreviewingCarryForward:
      isPreviewingCarryForward ?? this.isPreviewingCarryForward,
      carryPolicyItems: carryPolicyItems ?? this.carryPolicyItems,
      carryPreviewResult: clearCarryPreview ? null : carryPreviewResult ?? this.carryPreviewResult,
      isLoadingCarryPolicy: isLoadingCarryPolicy ?? this.isLoadingCarryPolicy,
      isSavingCarryPolicy: isSavingCarryPolicy ?? this.isSavingCarryPolicy,
    );
  }
}

class LeavesNotifier extends Notifier<LeavesState> {
  late LeaveRepository _repository;

  @override
  LeavesState build() {
    _repository = ref.read(leaveRepositoryProvider);
    ref.watch(sessionVersionProvider);
    return const LeavesState();
  }
  Future<void> loadCarryPolicyEditor({required int toYear}) async {
    state = state.copyWith(isLoadingCarryPolicy: true, clearError: true);

    try {
      final items = await _repository.getCarryPolicyItemsByYear(year: toYear);
      state = state.copyWith(
        carryPolicyItems: items,
        isLoadingCarryPolicy: false,
        clearCarryPreview: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingCarryPolicy: false,
        error: e.toString(),
      );
    }
  }

  void setCarryPolicyTypeEnabled({
    required String leaveTypeId,
    required bool isEnabled,
  }) {
    final updated = state.carryPolicyItems.map((e) {
      if (e.leaveTypeId != leaveTypeId) return e;
      return e.copyWith(isEnabled: isEnabled, maxDays: isEnabled ? e.maxDays : 0);
    }).toList();

    state = state.copyWith(carryPolicyItems: updated);
  }

  void setCarryPolicyTypeMaxDays({
    required String leaveTypeId,
    required double maxDays,
  }) {
    final normalized = maxDays < 0 ? 0.0 : maxDays;
    final updated = state.carryPolicyItems.map((e) {
      if (e.leaveTypeId != leaveTypeId) return e;
      return e.copyWith(maxDays: normalized);
    }).toList();

    state = state.copyWith(carryPolicyItems: updated);
  }

  Future<void> saveCarryPolicyEditor({required int toYear}) async {
    state = state.copyWith(isSavingCarryPolicy: true, clearError: true);

    try {
      for (final item in state.carryPolicyItems) {
        await _repository.upsertCarryPolicyItem(
          year: toYear,
          leaveTypeId: item.leaveTypeId,
          isEnabled: item.isEnabled,
          maxDays: item.maxDays,
        );
      }
      state = state.copyWith(isSavingCarryPolicy: false);
    } catch (e) {
      state = state.copyWith(
        isSavingCarryPolicy: false,
        error: e.toString(),
      );
    }
  }
  Future<int?> adminBootstrapLeaveBalancesForYear({
    required int year,
  }) async {
    state = state.copyWith(isBootstrapping: true, clearError: true);

    try {
      final inserted = await _repository.adminBootstrapLeaveBalancesForYear(
        year: year,
      );

      state = state.copyWith(isBootstrapping: false);
      return inserted;
    } catch (e) {
      state = state.copyWith(
        isBootstrapping: false,
        error: e.toString(),
      );
      return null;
    }
  }
  Future<Map<String, dynamic>?> adminPreviewCarryForward({
    required int fromYear,
    required int toYear,
  }) async {
    state = state.copyWith(
      isPreviewingCarryForward: true,
      clearError: true,
    );

    try {
      final result = await _repository.adminPreviewCarryForward(
        fromYear: fromYear,
        toYear: toYear,
      );
      state = state.copyWith(isPreviewingCarryForward: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isPreviewingCarryForward: false,
        error: e.toString(),
      );
      return null;
    }
  }



  Future<Map<String, dynamic>?> adminApplyCarryForward({
    required int fromYear,
    required int toYear,
  }) async {
    state = state.copyWith(
      isApplyingCarryForward: true,
      clearError: true,
    );

    try {
      final result = await _repository.adminApplyCarryForward(
        fromYear: fromYear,
        toYear: toYear,
      );

      state = state.copyWith(isApplyingCarryForward: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isApplyingCarryForward: false,
        error: e.toString(),
      );
      return null;
    }
  }
  Future<Map<String, int>?> adminPrepareLeaveBalancesForYear({
    required int year,
  }) async {
    state = state.copyWith(isBootstrapping: true, clearError: true);

    try {
      final result = await _repository.adminPrepareLeaveBalancesForYear(year: year);
      state = state.copyWith(isBootstrapping: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isBootstrapping: false,
        error: e.toString(),
      );
      return null;
    }
  }
  Future<void> loadLeavesData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final currentYear = DateTime.now().year;
      final results = await Future.wait([
        _repository.getLeaveTypes(),
        _repository.getMyLeaveBalances(year: currentYear),
        _repository.getMyLeaveRequests(),
      ]);

      state = state.copyWith(
        leaveTypes: results[0] as List<LeaveTypeModel>,
        balances: results[1] as List<LeaveBalanceModel>,
        myRequests: results[2] as List<LeaveRequestModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> submitLeaveRequest({
    required String leaveTypeId,
    required String startDate,
    required String endDate,
    String? reason,
    required String requestUnit,
    String? halfDayPart,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.submitLeaveRequest(
        leaveTypeId: leaveTypeId,
        startDate: startDate,
        endDate: endDate,
        reason: reason,
        requestUnit: requestUnit,
        halfDayPart: halfDayPart,
      );

      await loadLeavesData();
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> cancelLeaveRequest(String leaveId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.cancelLeaveRequest(leaveId: leaveId);
      await loadLeavesData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadPendingLeavesForReview() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final items = await _repository.getPendingLeavesForReview();
      state = state.copyWith(
        pendingReviewItems: items,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> approveLeaveRequest(String leaveId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.approveLeaveRequest(leaveId: leaveId);
      await loadPendingLeavesForReview();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> rejectLeaveRequest({
    required String leaveId,
    required String rejectionReason,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _repository.rejectLeaveRequest(
        leaveId: leaveId,
        rejectionReason: rejectionReason,
      );
      await loadPendingLeavesForReview();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  static const int _adminEmployeesPageSize = 20;

  Future<void> loadAdminLeaveData() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final leaveTypes = await _repository.getLeaveTypes();
      final employees = await _repository.searchEmployeesForAdmin(
        query: '',
        limit: _adminEmployeesPageSize,
        offset: 0,
      );

      state = state.copyWith(
        leaveTypes: leaveTypes,
        adminEmployees: employees,
        adminEmployeesOffset: employees.length,
        adminHasMoreEmployees: employees.length == _adminEmployeesPageSize,
        adminSearchQuery: '',
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> searchAdminEmployees(String query) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final employees = await _repository.searchEmployeesForAdmin(
        query: query,
        limit: _adminEmployeesPageSize,
        offset: 0,
      );

      state = state.copyWith(
        adminSearchQuery: query,
        adminEmployees: employees,
        adminEmployeesOffset: employees.length,
        adminHasMoreEmployees: employees.length == _adminEmployeesPageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreAdminEmployees() async {
    if (!state.adminHasMoreEmployees || state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final more = await _repository.searchEmployeesForAdmin(
        query: state.adminSearchQuery,
        limit: _adminEmployeesPageSize,
        offset: state.adminEmployeesOffset,
      );

      state = state.copyWith(
        adminEmployees: [...state.adminEmployees, ...more],
        adminEmployeesOffset: state.adminEmployeesOffset + more.length,
        adminHasMoreEmployees: more.length == _adminEmployeesPageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadAdminEmployeeBalances({
    required String employeeId,
    required int year,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final balances = await _repository.getEmployeeLeaveBalances(
        employeeId: employeeId,
        year: year,
      );

      state = state.copyWith(
        adminEmployeeBalances: balances,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> adminSetEmployeeLeaveBalance({
    required String employeeId,
    required String leaveTypeId,
    required int year,
    required double entitledDays,
    required double carryForwardDays,
    required bool isEnabled,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      await _repository.adminSetEmployeeLeaveBalance(
        employeeId: employeeId,
        leaveTypeId: leaveTypeId,
        year: year,
        entitledDays: entitledDays,
        carryForwardDays: carryForwardDays,
        isEnabled: isEnabled,
      );

      final balances = await _repository.getEmployeeLeaveBalances(
        employeeId: employeeId,
        year: year,
      );

      state = state.copyWith(
        adminEmployeeBalances: balances,
        isSubmitting: false,
      );
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
    }
  }
}

final leavesProvider = NotifierProvider<LeavesNotifier, LeavesState>(
  LeavesNotifier.new,
);