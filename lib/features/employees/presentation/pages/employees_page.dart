import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/employee_model.dart';
import '../providers/employees_provider.dart';
import '../../../attendance/data/models/work_schedule_model.dart';
import '../../../attendance/presentation/providers/work_schedules_provider.dart';
import '../../../attendance/presentation/pages/admin_employee_attendance_details_page.dart';
class EmployeesPage extends ConsumerStatefulWidget {
  const EmployeesPage({super.key});

  @override
  ConsumerState<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends ConsumerState<EmployeesPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(employeesProvider.notifier).loadEmployees();
      ref.read(workSchedulesProvider.notifier).loadSchedules();
    });
  }

  WorkScheduleModel? _findScheduleById(
      List<WorkScheduleModel> schedules,
      String? id,
      ) {
    if (id == null) return null;

    for (final schedule in schedules) {
      if (schedule.id == id) return schedule;
    }

    return null;
  }

  Future<void> _confirmEmployeeStatusChange({
    required EmployeeModel employee,
    required bool newValue,
  }) async {
    final isActivating = newValue;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final color = isActivating
            ? const Color(0xFF0F766E)
            : const Color(0xFFDC2626);

        final bgColor = isActivating
            ? const Color(0xFFECFDF5)
            : const Color(0xFFFEF2F2);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isActivating
                      ? Icons.verified_user_rounded
                      : Icons.block_rounded,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isActivating ? 'تفعيل الموظف' : 'تعطيل الموظف',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                employee.fullName,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                employee.email,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: color.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  isActivating
                      ? 'سيتم السماح لهذا الموظف بتسجيل الدخول واستخدام النظام حسب صلاحياته وجدول دوامه.'
                      : 'سيتم منع هذا الموظف من استخدام النظام حتى يتم إعادة تفعيله من الإدارة.',
                  style: TextStyle(
                    color: color,
                    height: 1.6,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: Icon(
                isActivating
                    ? Icons.check_circle_outline_rounded
                    : Icons.block_rounded,
              ),
              label: Text(isActivating ? 'تفعيل الآن' : 'تعطيل الآن'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (isActivating) {
      await ref.read(employeesProvider.notifier).activateEmployee(employee.id);
    } else {
      await ref.read(employeesProvider.notifier).deactivateEmployee(employee.id);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isActivating
              ? 'تم تفعيل الموظف بنجاح'
              : 'تم تعطيل الموظف بنجاح',
        ),
        backgroundColor:
        isActivating ? const Color(0xFF0F766E) : const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showWorkScheduleDialog({
    required EmployeeModel employee,
    required List<WorkScheduleModel> schedules,
  }) async {
    String? selectedScheduleId = employee.workScheduleId;

    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26),
              ),
              title: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: Color(0xFFECFDF5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تغيير جدول الدوام',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    employee.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    employee.email,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String?>(
                    value: selectedScheduleId,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'جدول الدوام',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('استخدام الجدول الافتراضي'),
                      ),
                      ...schedules.map(
                            (schedule) => DropdownMenuItem<String?>(
                          value: schedule.id,
                          child: Text(
                            '${schedule.name}${schedule.isDefault ? ' - افتراضي' : ''}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() {
                        selectedScheduleId = value;
                      });
                    },
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context, selectedScheduleId),
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('حفظ'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted) return;

    if (result == employee.workScheduleId) return;

    await ref.read(employeesProvider.notifier).updateEmployeeWorkSchedule(
      employeeId: employee.id,
      workScheduleId: result,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث جدول دوام الموظف'),
        backgroundColor: Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeesProvider);
    final schedulesState = ref.watch(workSchedulesProvider);

    final employees = state.employees;
    final activeCount =
        employees.where((employee) => employee.isActive == true).length;
    final inactiveCount = employees.length - activeCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'إدارة الموظفين',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'إضافة موظف',
            icon: const Icon(Icons.person_add_alt_1_rounded),
            onPressed: () async {
              await context.push('/activation-codes/generate');
            },
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: () {
              ref.read(employeesProvider.notifier).loadEmployees();
              ref.read(workSchedulesProvider.notifier).loadSchedules();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFDC2626),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          if (employees.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(employeesProvider.notifier).loadEmployees();
                await ref.read(workSchedulesProvider.notifier).loadSchedules();
              },
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Icon(
                    Icons.people_alt_outlined,
                    size: 76,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'لا يوجد موظفون حالياً',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(employeesProvider.notifier).loadEmployees();
              await ref.read(workSchedulesProvider.notifier).loadSchedules();
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _EmployeesSummaryHeader(
                  total: employees.length,
                  active: activeCount,
                  inactive: inactiveCount,
                ),
                const SizedBox(height: 16),
                ...employees.map((employee) {
                  final schedule = _findScheduleById(
                    schedulesState.schedules,
                    employee.workScheduleId,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _EmployeeCard(
                      employee: employee,
                      scheduleName: schedule?.name ?? 'الجدول الافتراضي',
                      isSchedulesLoading: schedulesState.isLoading,
                      onOpenAttendance: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AdminEmployeeAttendanceDetailsPage(
                              employeeId: employee.id,
                              employeeName: employee.fullName,
                              employeeEmail: employee.email,
                              currentLat: null,
                              currentLng: null,
                              todayStatus: null,
                              isOnDuty: false,
                              todayRecord: null,
                            ),
                          ),
                        );
                      },
                      onToggleStatus: (value) {
                        _confirmEmployeeStatusChange(
                          employee: employee,
                          newValue: value,
                        );
                      },
                      onChangeSchedule: () {
                        _showWorkScheduleDialog(
                          employee: employee,
                          schedules: schedulesState.schedules,
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmployeesSummaryHeader extends StatelessWidget {
  const _EmployeesSummaryHeader({
    required this.total,
    required this.active,
    required this.inactive,
  });

  final int total;
  final int active;
  final int inactive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF155E75),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              title: 'الإجمالي',
              value: total.toString(),
              icon: Icons.people_alt_rounded,
            ),
          ),
          Container(width: 1, height: 48, color: Colors.white24),
          Expanded(
            child: _SummaryItem(
              title: 'مفعل',
              value: active.toString(),
              icon: Icons.verified_user_rounded,
            ),
          ),
          Container(width: 1, height: 48, color: Colors.white24),
          Expanded(
            child: _SummaryItem(
              title: 'معطل',
              value: inactive.toString(),
              icon: Icons.block_rounded,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFCCFBF1),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.employee,
    required this.scheduleName,
    required this.isSchedulesLoading,
    required this.onOpenAttendance,
    required this.onToggleStatus,
    required this.onChangeSchedule,
  });

  final EmployeeModel employee;
  final String scheduleName;
  final bool isSchedulesLoading;
  final VoidCallback onOpenAttendance;
  final ValueChanged<bool> onToggleStatus;
  final VoidCallback onChangeSchedule;

  @override
  Widget build(BuildContext context) {
    final isActive = employee.isActive == true;
    final statusColor =
    isActive ? const Color(0xFF0F766E) : const Color(0xFFDC2626);
    final statusBg =
    isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Material(
        color: Colors.transparent,
        child: InkWell(
        borderRadius: BorderRadius.circular(24),
    onTap: onOpenAttendance,
    child: Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: const Color(0xFFE2E8F0)),
    boxShadow: [
    BoxShadow(
    color: Colors.black.withValues(alpha: 0.045),
    blurRadius: 22,
    offset: const Offset(0, 11),
    ),
    ],
    ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: statusBg,
                child: Icon(
                  isActive
                      ? Icons.person_rounded
                      : Icons.person_off_rounded,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  isActive ? 'مفعل' : 'معطل',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _EmployeeInfoRow(
            icon: Icons.admin_panel_settings_outlined,
            label: 'الدور',
            value: employee.role ?? 'employee',
          ),
          const SizedBox(height: 10),
          _EmployeeInfoRow(
            icon: Icons.schedule_rounded,
            label: 'الدوام',
            value: scheduleName,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;

              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _StatusActionButton(
                      isActive: isActive,
                      onTap: () => onToggleStatus(!isActive),
                    ),
                    const SizedBox(height: 10),
                    _ScheduleActionButton(
                      isLoading: isSchedulesLoading,
                      onTap: onChangeSchedule,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _StatusActionButton(
                      isActive: isActive,
                      onTap: () => onToggleStatus(!isActive),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ScheduleActionButton(
                      isLoading: isSchedulesLoading,
                      onTap: onChangeSchedule,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ), )));
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.isActive,
    required this.onTap,
  });

  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFFDC2626) : const Color(0xFF0F766E);
    final bg = isActive ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
                color: color,
                size: 19,
              ),
              const SizedBox(width: 8),
              Text(
                isActive ? 'تعطيل' : 'تفعيل',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleActionButton extends StatelessWidget {
  const _ScheduleActionButton({
    required this.isLoading,
    required this.onTap,
  });

  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isLoading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.schedule_rounded,
                color: Color(0xFF0F766E),
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'تغيير الدوام',
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeInfoRow extends StatelessWidget {
  const _EmployeeInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 19),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}