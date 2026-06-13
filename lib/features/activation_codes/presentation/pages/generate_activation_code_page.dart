import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/activation_codes_provider.dart';

class ActivationCodesPage extends ConsumerStatefulWidget {
  const ActivationCodesPage({super.key});

  @override
  ConsumerState<ActivationCodesPage> createState() =>
      _ActivationCodesPageState();
}

class _ActivationCodesPageState extends ConsumerState<ActivationCodesPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    Future.microtask(() {
      ref.read(activationCodesProvider.notifier).loadCodes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الكود بنجاح'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _shareCode(String code) async {
    await Share.share(
      'لديك كود تفعيل لتطبيق WorkPulse: $code',
    );
  }

  Future<void> _generateCode() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(activationCodesProvider.notifier).generateCode(
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    _nameController.clear();
    _emailController.clear();

    if (!mounted) return;

    _tabController.animateTo(0);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إنشاء كود التفعيل بنجاح'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activationCodesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'أكواد التفعيل',
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
            Tab(text: 'الأكواد'),
            Tab(text: 'إنشاء كود'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CodesListTab(
            isLoading: state.isLoading,
            error: state.error,
            codes: state.codes,
            onCopy: _copyCode,
            onShare: _shareCode,
          ),
          _CreateCodeTab(
            formKey: _formKey,
            nameController: _nameController,
            emailController: _emailController,
            isLoading: state.isLoading,
            generatedCode: state.generatedCode,
            onGenerate: _generateCode,
            onCopy: _copyCode,
            onShare: _shareCode,
          ),
        ],
      ),
    );
  }
}

class _CodesListTab extends ConsumerWidget {
  const _CodesListTab({
    required this.isLoading,
    required this.error,
    required this.codes,
    required this.onCopy,
    required this.onShare,
  });

  final bool isLoading;
  final String? error;
  final List<dynamic> codes;
  final Future<void> Function(String code) onCopy;
  final Future<void> Function(String code) onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Text(
          error!,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (codes.isEmpty) {
      return const Center(
        child: Text(
          'لا توجد أكواد تفعيل حالياً',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(activationCodesProvider.notifier).loadCodes();
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(18),
        itemCount: codes.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = codes[index];
          final isUsed = item.isUsed == true;

          return _ActivationCodeCard(
            code: item.code,
            fullName: item.fullName,
            email: item.email,
            isUsed: isUsed,
            onCopy: () => onCopy(item.code),
            onShare: () => onShare(item.code),
            onDelete: () async {
              final confirm = await _showDeleteDialog(
                context: context,
                isUsed: isUsed,
              );

              if (confirm != true) return;

              await ref
                  .read(activationCodesProvider.notifier)
                  .deleteCode(item.id);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف الكود بنجاح'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteDialog({
    required BuildContext context,
    required bool isUsed,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Icon(
                isUsed
                    ? Icons.delete_outline_rounded
                    : Icons.warning_amber_rounded,
                color:
                isUsed ? const Color(0xFFDC2626) : const Color(0xFFF59E0B),
              ),
              const SizedBox(width: 10),
              const Text(
                'تأكيد حذف الكود',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Text(
            isUsed
                ? 'هذا الكود مستخدم مسبقاً. هل تريد حذفه نهائياً من السجل؟'
                : 'تحذير مهم: هذا الكود غير مستخدم بعد. حذفه سيمنع الموظف المرتبط بهذا البريد من إنشاء حسابه باستخدام هذا الكود. هل أنت متأكد؟',
            style: const TextStyle(
              height: 1.6,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.delete_outline_rounded),
              label: const Text('حذف نهائي'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActivationCodeCard extends StatelessWidget {
  const _ActivationCodeCard({
    required this.code,
    required this.fullName,
    required this.email,
    required this.isUsed,
    required this.onCopy,
    required this.onShare,
    required this.onDelete,
  });

  final String code;
  final String fullName;
  final String email;
  final bool isUsed;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor =
    isUsed ? const Color(0xFF64748B) : const Color(0xFF0F766E);
    final statusBg =
    isUsed ? const Color(0xFFF1F5F9) : const Color(0xFFECFDF5);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F766E),
                      Color(0xFF155E75),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.vpn_key_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    letterSpacing: 1.1,
                  ),
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
                  isUsed ? 'تم استخدامه' : 'غير مستخدم',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CodeInfoRow(
            icon: Icons.person_outline_rounded,
            label: 'الاسم',
            value: fullName,
          ),
          const SizedBox(height: 10),
          _CodeInfoRow(
            icon: Icons.email_outlined,
            label: 'البريد',
            value: email,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _CodeActionButton(
                  title: 'نسخ',
                  icon: Icons.copy_rounded,
                  onTap: onCopy,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CodeActionButton(
                  title: 'مشاركة',
                  icon: Icons.share_rounded,
                  onTap: onShare,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CodeActionButton(
                  title: 'حذف',
                  icon: Icons.delete_outline_rounded,
                  onTap: onDelete,
                  isDanger: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CodeInfoRow extends StatelessWidget {
  const _CodeInfoRow({
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
        Icon(icon, color: const Color(0xFF64748B), size: 20),
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
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeActionButton extends StatelessWidget {
  const _CodeActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isDanger = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFDC2626) : const Color(0xFF0F766E);
    final bg = isDanger ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 19, color: color),
              const SizedBox(width: 7),
              Text(
                title,
                style: TextStyle(
                  color: color,
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

class _CreateCodeTab extends StatelessWidget {
  const _CreateCodeTab({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.isLoading,
    required this.generatedCode,
    required this.onGenerate,
    required this.onCopy,
    required this.onShare,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final bool isLoading;
  final String? generatedCode;
  final Future<void> Function() onGenerate;
  final Future<void> Function(String code) onCopy;
  final Future<void> Function(String code) onShare;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF0F766E),
                  Color(0xFF155E75),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F766E).withValues(alpha: 0.22),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  'إنشاء كود تفعيل جديد',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'أدخل بيانات الموظف وسيتم توليد كود خاص به لاستخدامه مرة واحدة.',
                  style: TextStyle(
                    color: Color(0xFFCCFBF1),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  _PremiumInput(
                    controller: nameController,
                    label: 'اسم الموظف',
                    icon: Icons.person_outline_rounded,
                    validatorText: 'اسم الموظف مطلوب',
                  ),
                  const SizedBox(height: 16),
                  _PremiumInput(
                    controller: emailController,
                    label: 'البريد الإلكتروني',
                    icon: Icons.email_outlined,
                    validatorText: 'البريد الإلكتروني مطلوب',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : onGenerate,
                      icon: isLoading
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.add_circle_outline_rounded),
                      label: const Text('إنشاء كود جديد'),
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
            ),
          ),
          if (generatedCode != null) ...[
            const SizedBox(height: 22),
            _GeneratedCodeBox(
              code: generatedCode!,
              onCopy: () => onCopy(generatedCode!),
              onShare: () => onShare(generatedCode!),
            ),
          ],
        ],
      ),
    );
  }
}

class _PremiumInput extends StatelessWidget {
  const _PremiumInput({
    required this.controller,
    required this.label,
    required this.icon,
    required this.validatorText,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String validatorText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: TextDirection.ltr,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return validatorText;
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: Color(0xFF0F766E),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _GeneratedCodeBox extends StatelessWidget {
  const _GeneratedCodeBox({
    required this.code,
    required this.onCopy,
    required this.onShare,
  });

  final String code;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return _ActivationCodeCard(
      code: code,
      fullName: 'تم إنشاء الكود بنجاح',
      email: 'يمكنك نسخه أو مشاركته الآن',
      isUsed: false,
      onCopy: onCopy,
      onShare: onShare,
      onDelete: () {},
    );
  }
}