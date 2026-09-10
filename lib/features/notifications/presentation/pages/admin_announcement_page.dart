import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notifications_provider.dart';

class AdminAnnouncementPage extends ConsumerStatefulWidget {
  const AdminAnnouncementPage({super.key});

  @override
  ConsumerState<AdminAnnouncementPage> createState() =>
      _AdminAnnouncementPageState();
}

class _AdminAnnouncementPageState extends ConsumerState<AdminAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _forAll = true;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).loadEmployees();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          'تعميم الموظفين',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                'اكتب عنوان واضح ومحتوى مباشر. يمكنك الإرسال لكل الموظفين أو لموظف محدد.',
                style: TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 13,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 14),

            const Text(
              'وجهة الإرسال',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),

            SegmentedButton<bool>(
              segments: const [
                ButtonSegment<bool>(
                  value: true,
                  icon: Icon(Icons.groups_2_outlined),
                  label: Text('كل الموظفين'),
                ),
                ButtonSegment<bool>(
                  value: false,
                  icon: Icon(Icons.person_outline_rounded),
                  label: Text('موظف محدد'),
                ),
              ],
              selected: <bool>{_forAll},
              onSelectionChanged: (value) {
                setState(() {
                  _forAll = value.first;
                  if (_forAll) _employeeId = null;
                });
              },
            ),

            const SizedBox(height: 12),

            if (!_forAll)
              DropdownButtonFormField<String>(
                initialValue: _employeeId,
                isExpanded: true,
                menuMaxHeight: 320,
                decoration: const InputDecoration(
                  labelText: 'اختيار موظف',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: state.employees.map((e) {
                  final id = e['id'].toString();
                  final fullName = (e['full_name'] ?? '').toString();
                  final email = (e['email'] ?? '').toString();
                  return DropdownMenuItem<String>(
                    value: id,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 16,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$fullName - $email',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return state.employees.map((e) {
                    final fullName = (e['full_name'] ?? '').toString();
                    final email = (e['email'] ?? '').toString();
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$fullName - $email',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  setState(() {
                    _employeeId = value;
                  });
                },
                validator: (_) {
                  if (_forAll) return null;
                  if (_employeeId == null) return 'اختر موظفاً';
                  return null;
                },
              ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _titleController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'عنوان الإشعار',
                hintText: 'مثال: تعديل توقيت الدوام ليوم الخميس',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 3) return 'العنوان مطلوب';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _bodyController,
              minLines: 5,
              maxLines: 7,
              decoration: const InputDecoration(
                labelText: 'محتوى الإشعار',
                hintText: 'اكتب نص التعميم الذي سيصل للموظفين',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) {
                if (v == null || v.trim().length < 5) return 'المحتوى مطلوب';
                return null;
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: state.isSending ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF94A3B8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: state.isSending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(Icons.send_rounded),
                label: Text(state.isSending ? 'جاري الإرسال...' : 'إرسال الإشعار'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(notificationsProvider.notifier).sendAnnouncement(
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      targetEmployeeId: _forAll ? null : _employeeId,
    );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الإشعار بنجاح')),
      );
      _titleController.clear();
      _bodyController.clear();
      setState(() {
        _forAll = true;
        _employeeId = null;
      });
    } else {
      final err = ref.read(notificationsProvider).error ?? 'فشل الإرسال';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}