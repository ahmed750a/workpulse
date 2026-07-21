import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/employee_model.dart';
import '../../data/repositories/employee_repository.dart';
import '../../../../../app/providers/supabase_provider.dart';

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final client = ref.read(supabaseClientProvider);
  return EmployeeRepository(client);
});

class EmployeesState {
  final List<EmployeeModel> employees;
  final bool isLoading;
  final String? error;

  const EmployeesState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
  });

  EmployeesState copyWith({
    List<EmployeeModel>? employees,
    bool? isLoading,
    String? error,
    bool clearError = false,           // ✅
  }) {
    return EmployeesState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,  // ✅
    );
  }
}

class EmployeesNotifier extends Notifier<EmployeesState> {
  late final EmployeeRepository repository;

  @override
  EmployeesState build() {
    repository = ref.read(employeeRepositoryProvider);
    ref.watch(sessionVersionProvider); // يربط الـ state بعمر الجلسة
    return const EmployeesState();     // بدون أي طلب شبكة هنا
  }
  Future<void> updateEmployeeWorkSchedule({
    required String employeeId,
    required String? workScheduleId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await repository.updateEmployeeWorkSchedule(
        employeeId: employeeId,
        workScheduleId: workScheduleId,
      );

      await loadEmployees();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }
  Future<void> loadEmployees() async {
    state = state.copyWith(isLoading: true);
    try {
      final list = await repository.getAllEmployees();
      state = state.copyWith(employees: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> activateEmployee(String id) async {
    await repository.activateEmployee(id);
    await loadEmployees();
  }

  Future<void> deactivateEmployee(String id) async {
    await repository.deactivateEmployee(id);
    await loadEmployees();
  }


}

final employeesProvider =
NotifierProvider<EmployeesNotifier, EmployeesState>(EmployeesNotifier.new);