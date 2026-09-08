import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpulse/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:workpulse/features/reports/pdf/reports_pdf_service.dart';

import '../../../shared/widgets/pdf_preview_page.dart';

class AdminLateReportPage extends ConsumerStatefulWidget {
  const AdminLateReportPage({super.key});

  @override
  ConsumerState<AdminLateReportPage> createState() => _AdminLateReportPageState();
}

class _AdminLateReportPageState extends ConsumerState<AdminLateReportPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMonth);
  }

  Future<void> _loadMonth() async {
    await ref.read(attendanceProvider.notifier).loadAdminAttendanceByMonth(
      month: _selectedMonth,
    );
  }

  Future<void> _refresh() async {
    await _loadMonth();
  }

  String _monthName(DateTime date) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'إبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadMonth();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    if (isCurrentMonth) return;

    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadMonth();
  }

  int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString() ?? '0') ?? 0;
  }
  String _statusTextAr(String status) {
    switch (status) {
      case 'checked_in':
        return 'داخل الدوام';
      case 'checked_out':
        return 'مكتمل';
      case 'late':
        return 'تأخير غير معتمد';
      case 'approved_late':
        return 'تأخير معتمد';
      case 'partially_approved_late':
        return 'تأخير جزئي';
      case 'late_checked_out':
        return 'مكتمل مع تأخير';
      case 'early_leave':
        return 'خروج مبكر غير معتمد';
      case 'early_leave_partial':
        return 'خروج مبكر جزئي';
      case 'early_leave_approved':
        return 'خروج مبكر معتمد';
      case 'hours_incomplete':
        return 'ساعات ناقصة';
      case 'hours_completed':
        return 'ساعات مكتملة';
      case 'hours_completed_with_overtime':
        return 'ساعات مكتملة مع إضافي';
      default:
        return status;
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(attendanceProvider);
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final reportLang = localeCode == 'en' ? 'en' : 'ar';

    final rows = <AdminLateReportPdfRow>[];
    for (final item in state.todayAdminAttendance) {
      final record = item['record'] as Map<String, dynamic>? ?? {};
      final approved = _toInt(record['approved_late_minutes']);
      final unapproved = _toInt(record['unapproved_late_minutes']);
      if (approved == 0 && unapproved == 0) continue;

      rows.add(
        AdminLateReportPdfRow(
          employeeName: item['employeeName']?.toString() ?? 'غير معروف',
          approvedMinutes: approved,
          unapprovedMinutes: unapproved,
          status: _statusTextAr(record['status']?.toString() ?? '--'),
        ),
      );
    }

    rows.sort((a, b) => b.totalMinutes.compareTo(a.totalMinutes));

    final totalApproved = rows.fold<int>(0, (sum, r) => sum + r.approvedMinutes);
    final totalUnapproved = rows.fold<int>(0, (sum, r) => sum + r.unapprovedMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('تقرير التأخير الشهري'),
        actions: [
          IconButton(
            tooltip: 'PDF',
            onPressed: rows.isEmpty
                ? null
                : () async {
              final monthLabel =
                  '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

              final bytes = await ReportsPdfService.instance.buildAdminLateReportPdf(
                rows: rows,
                generatedBy: reportLang == 'en' ? 'Administration' : 'الإدارة',
                monthLabel: monthLabel,
                lang: reportLang,
              );

              if (!context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(
                    bytes: bytes,
                    title: 'معاينة تقرير التأخير',
                    fileName:
                    'nabd_alamal_late_${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}.pdf',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf_rounded),
          ),
          IconButton(
            tooltip: 'تحديث',
            onPressed: state.isLoading ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: state.isLoading && rows.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _prevMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: const Color(0xFF0F766E),
                ),
                Expanded(
                  child: Text(
                    _monthName(_selectedMonth),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: const Color(0xFF0F766E),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          if (rows.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text(
                  'لا توجد حالات تأخير في هذا الشهر',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
          else ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'المعتمد: $totalApproved د | غير المعتمد: $totalUnapproved د | الحالات: ${rows.length}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),
            ...rows.map(
                  (r) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('الحالة: ${_statusTextAr(r.status)}'),
                    Text('معتمد: ${r.approvedMinutes} دقيقة'),
                    Text('غير معتمد: ${r.unapprovedMinutes} دقيقة'),
                    Text('الإجمالي: ${r.totalMinutes} دقيقة'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}