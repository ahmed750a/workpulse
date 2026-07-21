import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/permission_model.dart';
import '../../data/models/permission_review_item.dart';
import '../providers/permissions_provider.dart';
import '../../../../../core/utils/time_formatters.dart';
class AdminPermissionsPage extends ConsumerStatefulWidget {
  const AdminPermissionsPage({super.key});

  @override
  ConsumerState<AdminPermissionsPage> createState() =>
      _AdminPermissionsPageState();
}

class _AdminPermissionsPageState extends ConsumerState<AdminPermissionsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(permissionsProvider.notifier).loadPendingPermissionsForReview();
    });
  }

  String _typeText(String type) {
    switch (type) {
      case 'late_arrival':
        return 'تأخير دخول';
      case 'early_leave':
        return 'خروج مبكر';
      case 'exit_return':
        return 'خروج وعودة';
      default:
        return type;
    }
  }

  String _formatDate(String value) {
    try {
      final date = DateTime.parse(value);
      final y = date.year.toString().padLeft(4, '0');
      final m = date.month.toString().padLeft(2, '0');
      final d = date.day.toString().padLeft(2, '0');

      // اختر الشكل اللي تفضله:
      // return '$y-$m-$d';      // 2026-06-21
      return '$d/$m/$y';         // 21/06/2026
    } catch (_) {
      // لو string مش تاريخ أصلاً، نرجّع القيمة كما هي بدون تنسيق
      return value;
    }
  }



  Future<void> _approvePermission(PermissionModel permission) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'اعتماد الطلب',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'هل أنت متأكد من اعتماد طلب الإذن؟',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('اعتماد'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await ref
        .read(permissionsProvider.notifier)
        .approvePermission(permission.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم اعتماد طلب الإذن بنجاح'),
        backgroundColor: Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _rejectPermission(PermissionModel permission) async {
    final reasonController = TextEditingController();
    String? reason;

    try {
      reason = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'رفض الطلب',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            content: TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'اكتب سبب الرفض...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final text = reasonController.text.trim();
                  if (text.isEmpty) return;
                  Navigator.of(dialogContext).pop(text);
                },
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('رفض'),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      );
    } finally {
      // ✅ نضمن التخلص من الـ controller بعد إغلاق الـ dialog
      reasonController.dispose();
    }

    // لو المستخدم أغلق الديالوج بدون كتابة سبب
    if (reason == null || reason.trim().isEmpty) {
      return;
    }

    // ✅ نحدّث الحالة في Riverpod / Supabase
    await ref.read(permissionsProvider.notifier).rejectPermission(
      permissionId: permission.id,
      rejectionReason: reason.trim(),
    );

    if (!mounted) return;

    // ✅ إظهار رسالة نجاح بعد التحديث
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم رفض طلب الإذن'),
        backgroundColor: Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionsProvider);
    final pending = state.pendingReviewItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'مراجعة طلبات الأذونات',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading
                ? null
                : () {
              ref
                  .read(permissionsProvider.notifier)
                  .loadPendingPermissionsForReview();
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

          if (pending.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(permissionsProvider.notifier)
                    .loadPendingPermissionsForReview();
              },
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.22),
                  Icon(
                    Icons.assignment_turned_in_outlined,
                    size: 76,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'لا توجد طلبات أذونات معلقة',
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
              await ref
                  .read(permissionsProvider.notifier)
                  .loadPendingPermissionsForReview();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = pending[index];
                final permission = item.permission;

                return _AdminPermissionCard(
                  item: item,
                  typeText: _typeText,
                  formatDate: _formatDate,
                  onApprove: () => _approvePermission(permission),
                  onReject: () => _rejectPermission(permission),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminPermissionCard extends StatelessWidget {
  const _AdminPermissionCard({
    required this.item,
    required this.typeText,
    required this.formatDate,
    required this.onApprove,
    required this.onReject,
  });

  final PermissionReviewItem item;
  final String Function(String) typeText;
  final String Function(String) formatDate;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final permission = item.permission;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFECFDF5),
                child: Icon(
                  permission.type == 'late_arrival'
                      ? Icons.login_rounded
                      : permission.type == 'early_leave'
                      ? Icons.logout_rounded
                      : Icons.sync_alt_rounded,
                  color: const Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  typeText(permission.type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'قيد المراجعة',
                  style: TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'اسم الموظف',
            value: item.employeeName,
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.email_outlined,
            label: 'البريد',
            value: item.employeeEmail.isEmpty ? '--' : item.employeeEmail,
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: formatDate(permission.permissionDate),
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.work_history_outlined,
            label: 'بداية الدوام',
            value: formatTime12(item.scheduleStartTime),
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.event_available_outlined,
            label: 'نهاية الدوام',
            value: formatTime12(item.scheduleEndTime),
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.access_time_rounded,
            label: 'وقت الإذن',
            value:
            '${formatTime12(permission.startTime)} - ${formatTime12(permission.endTime)}',
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.timer_outlined,
            label: 'المدة',
            value: '${permission.totalMinutes} دقيقة',
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              permission.reason,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 14),

          _PermissionAnalysisBox(item: item),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onApprove,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('اعتماد'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFF0F766E),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('رفض'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _PermissionAnalysisBox extends StatelessWidget {
  const _PermissionAnalysisBox({
    required this.item,
  });

  final PermissionReviewItem item;

  String _analysisText() {
    final permission = item.permission;

    switch (permission.type) {
      case 'late_arrival':
        return 'هذا الطلب يسمح للموظف بتأخير تسجيل الدخول حتى ${formatTime12(permission.endTime)}. بعد الاعتماد سيتم مقارنة وقت الدخول الفعلي مع وقت الإذن.';
      case 'early_leave':
        return 'هذا الطلب يسمح للموظف بالخروج المبكر من الساعة ${formatTime12(permission.startTime)}. بعد الاعتماد سيتم مقارنة وقت الانصراف الفعلي مع نهاية الدوام الرسمية.';
      case 'exit_return':
        return 'هذا الطلب عبارة عن خروج وعودة من ${formatTime12(permission.startTime)} إلى ${formatTime12(permission.endTime)}. لاحقًا سيتم تتبع وقت الخروج والعودة الفعلي واعتماده من الإدارة.';
      default:
        return 'طلب إذن يحتاج مراجعة إدارية.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final permission = item.permission;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.insights_rounded,
                size: 18,
                color: Color(0xFF0F766E),
              ),
              SizedBox(width: 8),
              Text(
                'تحليل الطلب',
                style: TextStyle(
                  color: Color(0xFF0F766E),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _analysisText(),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'مدة الإذن المطلوبة: ${permission.totalMinutes} دقيقة',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          if (item.graceMinutes != null) ...[
            const SizedBox(height: 4),
            Text(
              'سماحية الدوام: ${item.graceMinutes} دقيقة',
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
class _InfoRow extends StatelessWidget {
  const _InfoRow({
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