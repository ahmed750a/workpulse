import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/correction_model.dart';
import '../providers/corrections_provider.dart';

class AdminCorrectionsPage extends ConsumerStatefulWidget {
  const AdminCorrectionsPage({super.key});

  @override
  ConsumerState<AdminCorrectionsPage> createState() =>
      _AdminCorrectionsPageState();
}

class _AdminCorrectionsPageState extends ConsumerState<AdminCorrectionsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(correctionsProvider.notifier).loadPendingForAdmin();
    });
  }

  String _typeText(String type) {
    switch (type) {
      case 'check_in':
        return 'تعديل حضور';
      case 'check_out':
        return 'تعديل انصراف';
      default:
        return type;
    }
  }

  String _fmtTime12(String? hhmmss) {
    if (hhmmss == null || hhmmss.trim().isEmpty) return '--';
    try {
      final parts = hhmmss.split(':');
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final period = h >= 12 ? 'م' : 'ص';
      final h12 = h % 12 == 0 ? 12 : h % 12;
      return '${h12.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')} $period';
    } catch (_) {
      return hhmmss;
    }
  }

  Future<void> _approve(String correctionId) async {
    await ref.read(correctionsProvider.notifier).approveCorrection(correctionId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم اعتماد طلب التعديل'),
        backgroundColor: Color(0xFF0F766E),
      ),
    );
  }

  Future<void> _reject(String correctionId) async {
    final controller = TextEditingController();
    String? reason;

    try {
      reason = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('رفض طلب التعديل'),
            content: TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'سبب الرفض'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final txt = controller.text.trim();
                  if (txt.isEmpty) return;
                  Navigator.pop(dialogContext, txt);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
                child: const Text('رفض'),
              ),
            ],
          );
        },
      );
    } finally {
      controller.dispose();
    }

    if (reason == null || reason.trim().isEmpty) return;

    await ref.read(correctionsProvider.notifier).rejectCorrection(
      correctionId: correctionId,
      rejectionReason: reason.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفض طلب التعديل'),
        backgroundColor: Color(0xFFDC2626),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(correctionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'مراجعة تعديل البصمات',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () => ref.read(correctionsProvider.notifier).loadPendingForAdmin(),
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

          if (state.pendingCorrections.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات تعديل معلقة',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(correctionsProvider.notifier).loadPendingForAdmin();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: state.pendingCorrections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final row = state.pendingCorrections[index];
                final c = row['correction'] as CorrectionModel;
                final employeeName = row['employeeName']?.toString() ?? 'غير معروف';
                final employeeEmail = row['employeeEmail']?.toString() ?? '';

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
                      Text(
                        employeeName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        employeeEmail,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('النوع: ${_typeText(c.type)}'),
                      Text('التاريخ: ${c.correctionDate}'),
                      Text('الوقت المطلوب: ${_fmtTime12(c.requestedTime)}'),
                      const SizedBox(height: 6),
                      Text(
                        c.reason,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _approve(c.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0F766E),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text('اعتماد'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _reject(c.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDC2626),
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text('رفض'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}