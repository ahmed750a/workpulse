import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../pages/permissions_page.dart';
import '../../data/models/permission_model.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      ref.read(permissionsProvider.notifier).loadMyPermissions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ✅ نوع الإذن بالعربي
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

  // ✅ لون الحالة
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
        return const Color(0xFF94A3B8);
    }
  }

  // ✅ نص الحالة
  String _statusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمد';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'طلبات الأذونات',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFCCFBF1),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'طلباتي'),
            Tab(text: 'طلب جديد'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ✅ تاب طلباتي
          _MyPermissionsTab(
            isLoading: state.isLoading,
            error: state.error,
            permissions: state.permissions,
            onCancel: (id) async {
              final confirm = await _showCancelDialog(context);
              if (confirm != true) return;
              await ref
                  .read(permissionsProvider.notifier)
                  .cancelPermission(id);
            },
            typeText: _typeText,
            statusColor: _statusColor,
            statusText: _statusText,
          ),

          // ✅ تاب طلب جديد
          _NewPermissionTab(
            isSubmitting: state.isSubmitting,
            error: state.error,
            onSubmit: ({
              required String date,
              required String startTime,
              required String endTime,
              required String type,
              required String reason,
            }) async {
              final success = await ref
                  .read(permissionsProvider.notifier)
                  .createPermission(
                permissionDate: date,
                startTime: startTime,
                endTime: endTime,
                type: type,
                reason: reason,
              );

              if (success && context.mounted) {
                _tabController.animateTo(0);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إرسال طلب الإذن بنجاح'),
                    backgroundColor: Color(0xFF0F766E),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            typeText: _typeText,
          ),
        ],
      ),
    );
  }

  Future<bool?> _showCancelDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: const Text(
          'إلغاء الطلب',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('هل تريد إلغاء هذا الطلب نهائياً؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }
}

// ✅ تاب طلباتي
class _MyPermissionsTab extends StatelessWidget {
  const _MyPermissionsTab({
    required this.isLoading,
    required this.error,
    required this.permissions,
    required this.onCancel,
    required this.typeText,
    required this.statusColor,
    required this.statusText,
  });

  final bool isLoading;
  final String? error;
  final List<PermissionModel> permissions;
  final Function(String) onCancel;
  final String Function(String) typeText;
  final Color Function(String) statusColor;
  final String Function(String) statusText;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (permissions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا يوجد طلبات أذونات سابقة',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: permissions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final permission = permissions[index];
          final color = statusColor(permission.status);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // نوع الإذن
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        typeText(permission.type),
                        style: const TextStyle(
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // الحالة
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        statusText(permission.status),
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // التاريخ والوقت
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      permission.permissionDate,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${permission.startTime} - ${permission.endTime}',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // السبب
                Text(
                  permission.reason,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                // زر الإلغاء للطلبات المعلقة فقط
                if (permission.status == 'pending') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => onCancel(permission.id),
                      icon: const Icon(
                        Icons.cancel_outlined,
                        size: 16,
                        color: Color(0xFFDC2626),
                      ),
                      label: const Text(
                        'إلغاء الطلب',
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
                // سبب الرفض
                if (permission.status == 'rejected' &&
                    permission.rejectionReason != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 14,
                          color: Color(0xFFDC2626),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'سبب الرفض: ${permission.rejectionReason}',
                            style: const TextStyle(
                              color: Color(0xFFDC2626),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

// ✅ تاب طلب جديد
class _NewPermissionTab extends StatefulWidget {
  const _NewPermissionTab({
    required this.isSubmitting,
    required this.error,
    required this.onSubmit,
    required this.typeText,
  });

  final bool isSubmitting;
  final String? error;
  final Future<void> Function({
  required String date,
  required String startTime,
  required String endTime,
  required String type,
  required String reason,
  }) onSubmit;
  final String Function(String) typeText;

  @override
  State<_NewPermissionTab> createState() => _NewPermissionTabState();
}

class _NewPermissionTabState extends State<_NewPermissionTab> {
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _selectedType = 'early_leave';

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ نوع الإذن
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'نوع الإذن',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ...['late_arrival', 'early_leave', 'exit_return']
                    .map((type) => RadioListTile<String>(
                  value: type,
                  groupValue: _selectedType,
                  onChanged: (v) =>
                      setState(() => _selectedType = v!),
                  title: Text(
                    widget.typeText(type),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  activeColor: const Color(0xFF0F766E),
                  contentPadding: EdgeInsets.zero,
                )),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ✅ التاريخ
          _PickerTile(
            icon: Icons.calendar_today_rounded,
            label: 'التاريخ',
            value: _formatDate(_selectedDate),
            onTap: _pickDate,
          ),

          const SizedBox(height: 10),

          // ✅ وقت البداية والنهاية
          Row(
            children: [
              Expanded(
                child: _PickerTile(
                  icon: Icons.access_time_rounded,
                  label: 'من الساعة',
                  value: _startTime.format(context),
                  onTap: _pickStartTime,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _PickerTile(
                  icon: Icons.access_time_filled_rounded,
                  label: 'إلى الساعة',
                  value: _endTime.format(context),
                  onTap: _pickEndTime,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ✅ السبب
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
                hintText: 'اكتب سبب الإذن...',
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ✅ رسالة الخطأ
          if (widget.error != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.error!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // ✅ زر الإرسال
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: widget.isSubmitting
                  ? null
                  : () async {
                if (_reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('يرجى كتابة سبب الإذن'),
                      backgroundColor: Color(0xFFDC2626),
                    ),
                  );
                  return;
                }

                await widget.onSubmit(
                  date: _formatDate(_selectedDate),
                  startTime: _formatTimeOfDay(_startTime),
                  endTime: _formatTimeOfDay(_endTime),
                  type: _selectedType,
                  reason: _reasonController.text.trim(),
                );
              },
              icon: widget.isSubmitting
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
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget مساعد لاختيار التاريخ والوقت
class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF0F766E), size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}