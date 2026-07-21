import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/leaves_provider.dart';

class AdminLeavesPage extends ConsumerStatefulWidget {
  const AdminLeavesPage({super.key});

  @override
  ConsumerState<AdminLeavesPage> createState() => _AdminLeavesPageState();
}

class _AdminLeavesPageState extends ConsumerState<AdminLeavesPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(leavesProvider.notifier).loadPendingLeavesForReview();
    });
  }

  Future<void> _approve(String leaveId) async {
    await ref.read(leavesProvider.notifier).approveLeaveRequest(leaveId);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم اعتماد طلب الإجازة'),
        backgroundColor: Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _reject(String leaveId) async {
    final reasonController = TextEditingController();
    String? reason;

    try {
      reason = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text('رفض طلب الإجازة'),
            content: TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'سبب الرفض',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  final txt = reasonController.text.trim();
                  if (txt.isEmpty) return;
                  Navigator.pop(dialogContext, txt);
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
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
      reasonController.dispose();
    }

    if (reason == null || reason.trim().isEmpty) return;

    await ref.read(leavesProvider.notifier).rejectLeaveRequest(
      leaveId: leaveId,
      rejectionReason: reason.trim(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفض طلب الإجازة'),
        backgroundColor: Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(leavesProvider);
    final items = state.pendingReviewItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('مراجعة طلبات الإجازة'),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(leavesProvider.notifier).loadPendingLeavesForReview();
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

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد طلبات إجازة معلقة',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(14),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final leave = item.leave;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.employeeEmail,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('نوع الإجازة: ${item.leaveTypeName ?? '--'}'),
                    Text('${leave.startDate} -> ${leave.endDate}'),
                    Text('المدة: ${leave.totalDays} يوم'),
                    if ((leave.reason ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        leave.reason!,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _approve(leave.id),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF0F766E),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('اعتماد'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _reject(leave.id),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFFDC2626),
                              foregroundColor: Colors.white,
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
          );
        },
      ),
    );
  }
}