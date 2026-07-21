import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/leave_request_model.dart';
import '../../providers/leaves_provider.dart';

class LeavesPage extends ConsumerStatefulWidget {
  const LeavesPage({super.key});

  @override
  ConsumerState<LeavesPage> createState() => _LeavesPageState();
}

class _LeavesPageState extends ConsumerState<LeavesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    Future.microtask(() {
      ref.read(leavesProvider.notifier).loadLeavesData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<bool?> _confirmCancel(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'إلغاء الطلب',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text('هل تريد إلغاء هذا الطلب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('لا'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('نعم'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leavesProvider);

    final activeBalances = state.balances.where((b) => b.isEnabled).toList();

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
          'طلبات الإجازات',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(leavesProvider.notifier).loadLeavesData(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFCCFBF1),
          labelStyle: const TextStyle(fontWeight: FontWeight.w800),
          tabs: const [
            Tab(text: 'طلباتي'),
            Tab(text: 'طلب جديد'),
            Tab(text: 'أرصدتي'),
          ],
        ),
      ),
      body: Column(
        children: [
          if (state.balances.isNotEmpty)
            _EmployeeLeaveSummary(
              totalEntitled: totalEntitled,
              totalUsed: totalUsed,
              totalPending: totalPending,
              totalRemaining: totalRemaining,
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _MyLeavesTab(
                  state: state,
                  onCancel: (leaveId) async {
                    final confirm = await _confirmCancel(context);
                    if (confirm != true) return;

                    await ref
                        .read(leavesProvider.notifier)
                        .cancelLeaveRequest(leaveId);

                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم إلغاء الطلب'),
                        backgroundColor: Color(0xFF0F766E),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _NewLeaveTab(
                  state: state,
                  onSubmit: ({
                    required String leaveTypeId,
                    required String startDate,
                    required String endDate,
                    String? reason,
                    required String requestUnit,
                    String? halfDayPart,
                  }) async {
                    final success = await ref
                        .read(leavesProvider.notifier)
                        .submitLeaveRequest(
                      leaveTypeId: leaveTypeId,
                      startDate: startDate,
                      endDate: endDate,
                      reason: reason,
                      requestUnit: requestUnit,
                      halfDayPart: halfDayPart,
                    );

                    if (!mounted) return;

                    if (success) {
                      _tabController.animateTo(0);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم إرسال طلب الإجازة بنجاح'),
                          backgroundColor: Color(0xFF0F766E),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
                _LeaveBalancesTab(state: state),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MyLeavesTab extends StatelessWidget {
  const _MyLeavesTab({
    required this.state,
    required this.onCancel,
  });

  final LeavesState state;
  final Future<void> Function(String leaveId) onCancel;

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'approved':
        return const Color(0xFF0F766E);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمدة';
      case 'rejected':
        return 'مرفوضة';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
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

    if (state.myRequests.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد طلبات إجازة حالياً',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(14),
      itemCount: state.myRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final leave = state.myRequests[index];
        final color = _statusColor(leave.status);

        return _LeaveCard(
          leave: leave,
          statusText: _statusText(leave.status),
          statusColor: color,
          onCancel: leave.status == 'pending' ? () => onCancel(leave.id) : null,
        );
      },
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.leave,
    required this.statusText,
    required this.statusColor,
    this.onCancel,
  });

  final LeaveRequestModel leave;
  final String statusText;
  final Color statusColor;
  final VoidCallback? onCancel;

  String _fmtDays(double value) =>
      value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  leave.leaveTypeName ?? 'إجازة',
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${leave.startDate} -> ${leave.endDate}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'عدد الأيام: ${_fmtDays(leave.totalDays)}',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
          if ((leave.reason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              leave.reason!,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if ((leave.rejectionReason ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'سبب الرفض: ${leave.rejectionReason}',
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(
                Icons.cancel_outlined,
                color: Color(0xFFDC2626),
              ),
              label: const Text(
                'إلغاء الطلب',
                style: TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NewLeaveTab extends StatefulWidget {
  const _NewLeaveTab({
    required this.state,
    required this.onSubmit,
  });

  final LeavesState state;
  final Future<void> Function({
  required String leaveTypeId,
  required String startDate,
  required String endDate,
  String? reason,
  required String requestUnit,
  String? halfDayPart,
  }) onSubmit;

  @override
  State<_NewLeaveTab> createState() => _NewLeaveTabState();
}

class _NewLeaveTabState extends State<_NewLeaveTab> {
  final TextEditingController _reasonController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  String? _leaveTypeId;
  String _requestUnit = 'full_day';
  String _halfDayPart = 'first_half';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(first) ? first : _startDate,
      firstDate: first,
      lastDate: DateTime(first.year + 5, 12, 31),
    );

    if (picked == null) return;

    setState(() {
      _startDate = picked;
      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate;
      }
    });
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(_startDate) ? _startDate : _endDate,
      firstDate: _startDate,
      lastDate: DateTime(_startDate.year + 5, 12, 31),
    );

    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final availableBalances =
    widget.state.balances.where((b) => b.isEnabled).toList();

    final availableTypeIds =
    availableBalances.map((b) => b.leaveTypeId).toSet();

    final leaveTypes = widget.state.leaveTypes
        .where((t) => availableTypeIds.contains(t.id))
        .toList();

    final selectedBalance = _leaveTypeId == null
        ? null
        : availableBalances
        .where((b) => b.leaveTypeId == _leaveTypeId)
        .isEmpty
        ? null
        : availableBalances
        .firstWhere((b) => b.leaveTypeId == _leaveTypeId);

    if (leaveTypes.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أنواع إجازات مفعلة لك حاليا. راجع الإدارة.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _leaveTypeId,
                    decoration: InputDecoration(
                      labelText: 'نوع الإجازة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: leaveTypes
                        .map(
                          (t) => DropdownMenuItem<String>(
                        value: t.id,
                        child: Text(t.name),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _leaveTypeId = value);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'نوع الطلب',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<String>(
                        value: 'full_day',
                        groupValue: _requestUnit,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() => _requestUnit = v);
                        },
                        title: const Text('يوم كامل'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: 'half_day',
                        groupValue: _requestUnit,
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            _requestUnit = v;
                            _endDate = _startDate;
                          });
                        },
                        title: const Text('نصف يوم'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_requestUnit == 'half_day') ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _halfDayPart,
                          decoration: InputDecoration(
                            labelText: 'جزء اليوم',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'first_half',
                              child: Text('النصف الأول'),
                            ),
                            DropdownMenuItem(
                              value: 'second_half',
                              child: Text('النصف الثاني'),
                            ),
                          ],
                          onChanged: (v) {
                            if (v == null) return;
                            setState(() => _halfDayPart = v);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _DateTile(
                  title: 'تاريخ البداية',
                  value: _fmtDate(_startDate),
                  onTap: _pickStartDate,
                ),
                if (_requestUnit == 'full_day') ...[
                  const SizedBox(height: 10),
                  _DateTile(
                    title: 'تاريخ النهاية',
                    value: _fmtDate(_endDate),
                    onTap: _pickEndDate,
                  ),
                ],
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'سبب الإجازة',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ),
                if (selectedBalance != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Text(
                      'المتبقي لهذا النوع: ${selectedBalance.remainingDays % 1 == 0 ? selectedBalance.remainingDays.toInt() : selectedBalance.remainingDays.toStringAsFixed(1)} يوم',
                      style: const TextStyle(
                        color: Color(0xFF0F766E),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                if (widget.state.error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.state.error!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 10),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: widget.state.isSubmitting
                    ? null
                    : () async {
                  if (_leaveTypeId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('اختر نوع الإجازة')),
                    );
                    return;
                  }

                  final start = _fmtDate(_startDate);
                  final end = _requestUnit == 'half_day'
                      ? start
                      : _fmtDate(_endDate);

                  await widget.onSubmit(
                    leaveTypeId: _leaveTypeId!,
                    startDate: start,
                    endDate: end,
                    reason: _reasonController.text.trim().isEmpty
                        ? null
                        : _reasonController.text.trim(),
                    requestUnit: _requestUnit,
                    halfDayPart:
                    _requestUnit == 'half_day' ? _halfDayPart : null,
                  );
                },
                icon: widget.state.isSubmitting
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded),
                label: const Text('إرسال الطلب'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Color(0xFF0F766E),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                '$title: $value',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmployeeLeaveSummary extends StatelessWidget {
  const _EmployeeLeaveSummary({
    required this.totalEntitled,
    required this.totalUsed,
    required this.totalPending,
    required this.totalRemaining,
  });

  final double totalEntitled;
  final double totalUsed;
  final double totalPending;
  final double totalRemaining;

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF155E75)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _EmployeeSummaryMetric(label: 'الإجمالي', value: _fmt(totalEntitled)),
            _EmployeeSummaryMetric(label: 'المستخدم', value: _fmt(totalUsed)),
            _EmployeeSummaryMetric(label: 'المعلق', value: _fmt(totalPending)),
            _EmployeeSummaryMetric(label: 'المتبقي', value: _fmt(totalRemaining)),
          ],
        ),
      ),
    );
  }
}

class _EmployeeSummaryMetric extends StatelessWidget {
  const _EmployeeSummaryMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 105,
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

class _LeaveBalancesTab extends StatelessWidget {
  const _LeaveBalancesTab({
    required this.state,
  });

  final LeavesState state;

  String _fmt(double v) => v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    if (state.isLoading && state.balances.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.balances.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
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

    if (state.balances.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أرصدة إجازات لعرضها حالياً',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final balances = [...state.balances]
      ..sort((a, b) => (a.leaveTypeName ?? '').compareTo(b.leaveTypeName ?? ''));

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      itemCount: balances.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final b = balances[index];
        final total = b.entitledDays + b.carryForwardDays;
        final consumed = b.usedDays + b.pendingDays;
        final progress = total <= 0 ? 0.0 : (consumed / total).clamp(0.0, 1.0);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      b.leaveTypeName ?? 'نوع إجازة',
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: b.isEnabled
                          ? const Color(0xFFECFDF5)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      b.isEnabled ? 'مفعل' : 'غير مفعل',
                      style: TextStyle(
                        color: b.isEnabled
                            ? const Color(0xFF0F766E)
                            : const Color(0xFF64748B),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: progress,
                  backgroundColor: const Color(0xFFE2E8F0),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    b.remainingDays > 0 ? const Color(0xFF0F766E) : const Color(0xFFDC2626),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _BalanceChip(label: 'المستحق', value: _fmt(b.entitledDays)),
                  _BalanceChip(label: 'المرحل', value: _fmt(b.carryForwardDays)),
                  _BalanceChip(label: 'المستخدم', value: _fmt(b.usedDays)),
                  _BalanceChip(label: 'المعلق', value: _fmt(b.pendingDays)),
                  _BalanceChip(
                    label: 'المتبقي',
                    value: _fmt(b.remainingDays),
                    highlight: true,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: highlight ? const Color(0xFF0F766E) : const Color(0xFF334155),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}