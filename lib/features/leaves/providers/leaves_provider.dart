import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../data/models/admin_employee_item.dart';
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
  final String? error;
  final String adminSearchQuery;
  final int adminEmployeesOffset;
  final bool adminHasMoreEmployees;
  const LeavesState({
    this.leaveTypes = const [],
    this.balances = const [],
    this.myRequests = const [],
    this.pendingReviewItems = const [],
    this.adminEmployees = const [],
    this.adminEmployeeBalances = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.adminSearchQuery = '',
    this.adminEmployeesOffset = 0,
    this.adminHasMoreEmployees = true,
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
    String? error,
    bool clearError = false,
  String? adminSearchQuery,
  int? adminEmployeesOffset,
  bool? adminHasMoreEmployees,
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
      error: clearError ? null : error ?? this.error,
      adminSearchQuery: adminSearchQuery ?? this.adminSearchQuery,
      adminEmployeesOffset: adminEmployeesOffset ?? this.adminEmployeesOffset,
      adminHasMoreEmployees: adminHasMoreEmployees ?? this.adminHasMoreEmployees,
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