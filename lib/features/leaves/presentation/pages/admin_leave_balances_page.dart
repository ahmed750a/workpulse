import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/admin_employee_item.dart';
import '../../data/models/leave_balance_model.dart';
import '../../providers/leaves_provider.dart';

class AdminLeaveBalancesPage extends ConsumerStatefulWidget {
  const AdminLeaveBalancesPage({super.key});

  @override
  ConsumerState<AdminLeaveBalancesPage> createState() =>
      _AdminLeaveBalancesPageState();
}

class _AdminLeaveBalancesPageState
    extends ConsumerState<AdminLeaveBalancesPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  AdminEmployeeItem? _selectedEmployee;
  int _selectedYear = DateTime.now().year;

  final Map<String, TextEditingController> _entitledControllers = {};
  final Map<String, TextEditingController> _carryControllers = {};
  final Map<String, bool> _enabledMap = {};
  final Set<String> _savingLeaveTypeIds = <String>{};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leavesProvider.notifier).loadAdminLeaveData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();

    for (final c in _entitledControllers.values) {
      c.dispose();
    }
    for (final c in _carryControllers.values) {
      c.dispose();
    }

    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(leavesProvider.notifier).searchAdminEmployees(value);
    });
  }

  Future<void> _loadBalances() async {
    if (_selectedEmployee == null) return;

    await ref.read(leavesProvider.notifier).loadAdminEmployeeBalances(
      employeeId: _selectedEmployee!.id,
      year: _selectedYear,
    );

    final balances = ref.read(leavesProvider).adminEmployeeBalances;
    for (final b in balances) {
      _entitledControllers[b.leaveTypeId]?.dispose();
      _entitledControllers[b.leaveTypeId] =
          TextEditingController(text: b.entitledDays.toStringAsFixed(1));

      _carryControllers[b.leaveTypeId]?.dispose();
      _carryControllers[b.leaveTypeId] =
          TextEditingController(text: b.carryForwardDays.toStringAsFixed(1));

      _enabledMap[b.leaveTypeId] = b.isEnabled;
    }

    if (mounted) setState(() {});
  }

  double? _parseNumber(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    return double.tryParse(normalized);
  }

  Future<void> _saveOneBalance(LeaveBalanceModel balance) async {
    if (_selectedEmployee == null) return;

    final entitledTxt =
        _entitledControllers[balance.leaveTypeId]?.text.trim() ?? '';
    final carryTxt = _carryControllers[balance.leaveTypeId]?.text.trim() ?? '0';

    final entitled = _parseNumber(entitledTxt);
    final carry = _parseNumber(carryTxt);
    final enabled = _enabledMap[balance.leaveTypeId] ?? false;

    if (entitled == null || carry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أدخل قيما رقمية صحيحة')),
      );
      return;
    }

    final minimumRequired = balance.usedDays + balance.pendingDays;
    if ((entitled + carry) < minimumRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن الحفظ: (المستحق + المرحل) أقل من (المستخدم + المعلق) = ${minimumRequired.toStringAsFixed(1)}',
          ),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() {
      _savingLeaveTypeIds.add(balance.leaveTypeId);
    });

    try {
      await ref.read(leavesProvider.notifier).adminSetEmployeeLeaveBalance(
        employeeId: _selectedEmployee!.id,
        leaveTypeId: balance.leaveTypeId,
        year: _selectedYear,
        entitledDays: entitled,
        carryForwardDays: carry,
        isEnabled: enabled,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ رصيد: ${balance.leaveTypeName ?? '--'}'),
          backgroundColor: const Color(0xFF0F766E),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _savingLeaveTypeIds.remove(balance.leaveTypeId);
        });
      }
    }
  }

  Future<void> _openEmployeePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final state = ref.watch(leavesProvider);

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.78,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'اختيار موظف',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'ابحث بالاسم أو البريد',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: state.adminEmployees.isEmpty
                        ? const Center(
                      child: Text(
                        'لا يوجد موظفون',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                        : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount:
                      state.adminEmployees.length + (state.adminHasMoreEmployees ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (state.adminHasMoreEmployees &&
                            index == state.adminEmployees.length) {
                          return OutlinedButton.icon(
                            onPressed: () {
                              ref
                                  .read(leavesProvider.notifier)
                                  .loadMoreAdminEmployees();
                            },
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('تحميل المزيد'),
                          );
                        }

                        final employee = state.adminEmployees[index];
                        final isSelected = _selectedEmployee?.id == employee.id;

                        return Material(
                          color: isSelected
                              ? const Color(0xFFECFDF5)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () async {
                              setState(() {
                                _selectedEmployee = employee;
                              });
                              Navigator.of(context).pop();
                              await _loadBalances();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    employee.fullName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w900,
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
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leavesProvider);
    final years = List<int>.generate(7, (i) => DateTime.now().year - 3 + i);
    final balances = state.adminEmployeeBalances;

    final activeBalances = balances.where(
          (b) => _enabledMap[b.leaveTypeId] ?? b.isEnabled,
    );

    final totalEntitled = activeBalances.fold<double>(
      0,
          (sum, b) => sum + b.entitledDays + b.carryForwardDays,
    );
    final totalUsed = activeBalances.fold<double>(
      0,
          (sum, b) => sum + b.usedDays,
    );
    final totalPending = activeBalances.fold<double>(
      0,
          (sum, b) => sum + b.pendingDays,
    );
    final totalRemaining = activeBalances.fold<double>(
      0,
          (sum, b) => sum + b.remainingDays,
    );
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'إدارة أرصدة الإجازات',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: () async {
              await ref.read(leavesProvider.notifier).loadAdminLeaveData();
              if (_selectedEmployee != null) {
                await _loadBalances();
              }
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _openEmployeePicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_search_rounded,
                                color: Color(0xFF0F766E)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _selectedEmployee == null
                                    ? 'اختر موظف'
                                    : _selectedEmployee!.fullName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: _selectedEmployee == null
                                      ? const Color(0xFF64748B)
                                      : const Color(0xFF0F172A),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedYear,
                      underline: const SizedBox.shrink(),
                      items: years
                          .map((y) => DropdownMenuItem<int>(
                        value: y,
                        child: Text('$y'),
                      ))
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _selectedYear = v);
                        await _loadBalances();
                      },
                    ),
                  ),
                ],
              ),
            ),

            if (_selectedEmployee != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _SummaryMetric(label: 'الإجمالي', value: _fmt(totalEntitled)),
                      _SummaryMetric(label: 'المستخدم', value: _fmt(totalUsed)),
                      _SummaryMetric(label: 'المعلق', value: _fmt(totalPending)),
                      _SummaryMetric(label: 'المتبقي', value: _fmt(totalRemaining)),
                    ],
                  ),
                ),
              ),

            Expanded(
              child: _selectedEmployee == null
                  ? const Center(
                child: Text(
                  'اختر موظفا لعرض وتعديل أرصدة الإجازات',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
                  : balances.isEmpty
                  ? const Center(
                child: Text(
                  'لا توجد أرصدة لهذه السنة',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
                  : ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                itemCount: balances.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final b = balances[index];

                  final entitledController =
                  _entitledControllers.putIfAbsent(
                    b.leaveTypeId,
                        () => TextEditingController(
                      text: b.entitledDays.toStringAsFixed(1),
                    ),
                  );

                  final carryController = _carryControllers.putIfAbsent(
                    b.leaveTypeId,
                        () => TextEditingController(
                      text: b.carryForwardDays.toStringAsFixed(1),
                    ),
                  );

                  final enabled = _enabledMap[b.leaveTypeId] ?? b.isEnabled;
                  final isSaving = _savingLeaveTypeIds.contains(b.leaveTypeId);

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border:
                      Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                b.leaveTypeName ?? '--',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: enabled
                                    ? const Color(0xFFECFDF5)
                                    : const Color(0xFFFEF2F2),
                                borderRadius:
                                BorderRadius.circular(999),
                              ),
                              child: Text(
                                enabled ? 'مفعل' : 'غير مفعل',
                                style: TextStyle(
                                  color: enabled
                                      ? const Color(0xFF0F766E)
                                      : const Color(0xFFDC2626),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch(
                              value: enabled,
                              onChanged: (v) {
                                setState(() {
                                  _enabledMap[b.leaveTypeId] = v;
                                });
                              },
                              activeColor: const Color(0xFF0F766E),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _ReadMetric(
                              label: 'المستخدم',
                              value: _fmt(b.usedDays),
                            ),
                            _ReadMetric(
                              label: 'المعلق',
                              value: _fmt(b.pendingDays),
                            ),
                            _ReadMetric(
                              label: 'المتبقي',
                              value: _fmt(b.remainingDays),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: entitledController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'الرصيد المستحق (أيام)',
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: carryController,
                          keyboardType:
                          const TextInputType.numberWithOptions(
                              decimal: true),
                          decoration: InputDecoration(
                            labelText: 'الرصيد المرحل',
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: isSaving
                                ? null
                                : () => _saveOneBalance(b),
                            icon: isSaving
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.save_rounded),
                            label: Text(
                              isSaving ? 'جاري الحفظ...' : 'حفظ',
                            ),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor:
                              const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFCCFBF1),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadMetric extends StatelessWidget {
  const _ReadMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}