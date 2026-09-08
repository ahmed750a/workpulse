import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/providers/supabase_provider.dart';
import '../../data/models/admin_correction_report_row_model.dart';
import '../../data/models/admin_geofence_report_row_model.dart';
import '../../data/models/admin_leave_monthly_report_row_model.dart';
import '../../data/models/admin_permissions_report_row_model.dart';
import '../../data/models/admin_today_summary_model.dart';
import '../../data/models/admin_today_violation_model.dart';
import '../../data/models/admin_today_work_hours_model.dart';
import '../../data/repositories/reports_repository.dart';

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return ReportsRepository(client);
});

class ReportsState {
  final AdminTodaySummaryModel? adminTodaySummary;
  final List<AdminTodayViolationModel> todayViolations;
  final List<AdminTodayWorkHoursModel> monthlyWorkHours;
  final List<AdminLeaveMonthlyReportRowModel> adminLeavesMonthly;
  final List<AdminPermissionsReportRowModel> adminPermissionsMonthly;
  final List<AdminCorrectionReportRowModel> adminCorrectionsMonthly;
  final List<AdminGeofenceReportRowModel> adminGeofenceMonthly;
  final bool isLoading;
  final String? error;

  // backward compatibility
  List<AdminTodayWorkHoursModel> get todayWorkHours => monthlyWorkHours;

  const ReportsState({
    this.adminTodaySummary,
    this.todayViolations = const [],
    this.monthlyWorkHours = const [],
    this.adminLeavesMonthly = const [],
    this.adminPermissionsMonthly = const [],
    this.adminCorrectionsMonthly = const [],
    this.adminGeofenceMonthly = const [],
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    AdminTodaySummaryModel? adminTodaySummary,
    List<AdminTodayViolationModel>? todayViolations,
    List<AdminTodayWorkHoursModel>? monthlyWorkHours,
    List<AdminLeaveMonthlyReportRowModel>? adminLeavesMonthly,
    List<AdminPermissionsReportRowModel>? adminPermissionsMonthly,
    List<AdminCorrectionReportRowModel>? adminCorrectionsMonthly,
    List<AdminGeofenceReportRowModel>? adminGeofenceMonthly,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ReportsState(
      adminTodaySummary: adminTodaySummary ?? this.adminTodaySummary,
      todayViolations: todayViolations ?? this.todayViolations,
      monthlyWorkHours: monthlyWorkHours ?? this.monthlyWorkHours,
      adminLeavesMonthly: adminLeavesMonthly ?? this.adminLeavesMonthly,
      adminPermissionsMonthly:
      adminPermissionsMonthly ?? this.adminPermissionsMonthly,
      adminCorrectionsMonthly:
      adminCorrectionsMonthly ?? this.adminCorrectionsMonthly,
      adminGeofenceMonthly: adminGeofenceMonthly ?? this.adminGeofenceMonthly,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class ReportsNotifier extends Notifier<ReportsState> {
  late ReportsRepository _repository;

  @override
  ReportsState build() {
    _repository = ref.read(reportsRepositoryProvider);
    ref.watch(sessionVersionProvider);
    return const ReportsState();
  }

  Future<void> loadAdminTodaySummary() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final summary = await _repository.getAdminTodaySummary();
      state = state.copyWith(adminTodaySummary: summary, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminTodayViolations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminTodayViolations(limit: 50);
      state = state.copyWith(todayViolations: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminWorkHoursReportByMonth({
    required DateTime month,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminWorkHoursReportByMonth(month: month);
      state = state.copyWith(monthlyWorkHours: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminLeavesReportByMonth({
    required DateTime month,
    String status = 'all',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminLeavesReportByMonth(
        month: month,
        status: status,
      );
      state = state.copyWith(adminLeavesMonthly: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminPermissionsReportByMonth({
    required DateTime month,
    String status = 'all',
    String type = 'all',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminPermissionsReportByMonth(
        month: month,
        status: status,
        type: type,
      );
      state = state.copyWith(adminPermissionsMonthly: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminCorrectionsReportByMonth({
    required DateTime month,
    String status = 'all',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminCorrectionsReportByMonth(
        month: month,
        status: status,
      );
      state = state.copyWith(adminCorrectionsMonthly: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> loadAdminGeofenceReportByMonth({
    required DateTime month,
    bool outsideOnly = false,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final rows = await _repository.getAdminGeofenceReportByMonth(
        month: month,
        outsideOnly: outsideOnly,
      );
      state = state.copyWith(adminGeofenceMonthly: rows, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }
}

final reportsProvider =
NotifierProvider<ReportsNotifier, ReportsState>(ReportsNotifier.new);