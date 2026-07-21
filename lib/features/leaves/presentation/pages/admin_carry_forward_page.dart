import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/leaves_provider.dart';

class AdminCarryForwardPage extends ConsumerStatefulWidget {
  const AdminCarryForwardPage({super.key});

  @override
  ConsumerState<AdminCarryForwardPage> createState() => _AdminCarryForwardPageState();
}

class _AdminCarryForwardPageState extends ConsumerState<AdminCarryForwardPage> {
  int _fromYear = DateTime.now().year - 1;
  int _toYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(leavesProvider.notifier).loadCarryPolicyEditor(toYear: _toYear);
    });
  }

  bool get _isYearPairValid => _toYear == _fromYear + 1;

  Future<void> _reloadPolicy() async {
    await ref.read(leavesProvider.notifier).loadCarryPolicyEditor(toYear: _toYear);
  }

  Future<void> _preview() async {
    if (!_isYearPairValid) return;
    await ref.read(leavesProvider.notifier).adminPreviewCarryForward(
      fromYear: _fromYear,
      toYear: _toYear,
    );
  }

  Future<void> _apply() async {
    if (!_isYearPairValid) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تنفيذ الترحيل'),
        content: Text('سيتم ترحيل رصيد الإجازات من $_fromYear إلى $_toYear. هل تريد المتابعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تنفيذ'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ref.read(leavesProvider.notifier).adminApplyCarryForward(
      fromYear: _fromYear,
      toYear: _toYear,
    );

    if (!mounted || result == null) return;

    final upserted = (result['upserted_count'] as num?)?.toInt() ?? 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم الترحيل بنجاح. عدد السجلات المتأثرة: $upserted'),
        backgroundColor: const Color(0xFF0F766E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leavesProvider);
    final years = List<int>.generate(10, (i) => DateTime.now().year - 5 + i);
    final preview = state.carryPreviewResult;
    final policyItems = state.carryPolicyItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'ترحيل الإجازات السنوي',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoadingCarryPolicy ? null : _reloadPolicy,
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _fromYear,
                          decoration: const InputDecoration(
                            labelText: 'من سنة',
                            border: OutlineInputBorder(),
                          ),
                          items: years
                              .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
                              .toList(),
                          onChanged: (v) async {
                            if (v == null) return;
                            setState(() => _fromYear = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _toYear,
                          decoration: const InputDecoration(
                            labelText: 'إلى سنة',
                            border: OutlineInputBorder(),
                          ),
                          items: years
                              .map((y) => DropdownMenuItem<int>(value: y, child: Text('$y')))
                              .toList(),
                          onChanged: (v) async {
                            if (v == null) return;
                            setState(() => _toYear = v);
                            await _reloadPolicy();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _isYearPairValid
                          ? 'ممتاز: الترحيل مسموح من سنة إلى السنة التالية مباشرة.'
                          : 'خطأ: يجب أن تكون السنة الهدف = سنة المصدر + 1.',
                      style: TextStyle(
                        color: _isYearPairValid ? const Color(0xFF0F766E) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoadingCarryPolicy
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                children: [
                  const Text(
                    'سياسة الترحيل حسب النوع',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...policyItems.map((item) {
                    final maxController =
                    TextEditingController(text: item.maxDays.toStringAsFixed(1));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.leaveTypeName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Switch(
                                value: item.isEnabled,
                                activeColor: const Color(0xFF0F766E),
                                onChanged: (v) {
                                  ref
                                      .read(leavesProvider.notifier)
                                      .setCarryPolicyTypeEnabled(
                                    leaveTypeId: item.leaveTypeId,
                                    isEnabled: v,
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: maxController,
                            enabled: item.isEnabled,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'الحد الأعلى للترحيل (أيام)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              final parsed =
                              double.tryParse(value.trim().replaceAll(',', '.'));
                              if (parsed == null) return;
                              ref.read(leavesProvider.notifier).setCarryPolicyTypeMaxDays(
                                leaveTypeId: item.leaveTypeId,
                                maxDays: parsed,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: state.isSavingCarryPolicy
                          ? null
                          : () => ref.read(leavesProvider.notifier).saveCarryPolicyEditor(
                        toYear: _toYear,
                      ),
                      icon: state.isSavingCarryPolicy
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.save_rounded),
                      label: const Text('حفظ سياسة السنة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: (!_isYearPairValid || state.isPreviewingCarryForward)
                              ? null
                              : _preview,
                          icon: state.isPreviewingCarryForward
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                              : const Icon(Icons.visibility_rounded),
                          label: const Text('معاينة'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: (!_isYearPairValid || state.isApplyingCarryForward)
                              ? null
                              : _apply,
                          icon: state.isApplyingCarryForward
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.sync_alt_rounded),
                          label: const Text('تنفيذ الترحيل'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F766E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (preview != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('السياسة موجودة: ${preview['policy_found'] == true ? 'نعم' : 'لا'}'),
                          Text('حالة الترحيل: ${preview['policy_enabled'] == true ? 'مفعل' : 'متوقف'}'),
                          Text('عدد الموظفين النشطين: ${preview['active_employees'] ?? 0}'),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}