import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpulse/features/reports/presentation/providers/reports_provider.dart';
import 'package:workpulse/features/reports/pdf/reports_pdf_service.dart';
import 'package:workpulse/shared/widgets/pdf_preview_page.dart';

class AdminWorkHoursReportPage extends ConsumerStatefulWidget {
  const AdminWorkHoursReportPage({super.key});

  @override
  ConsumerState<AdminWorkHoursReportPage> createState() =>
      _AdminWorkHoursReportPageState();
}

class _AdminWorkHoursReportPageState extends ConsumerState<AdminWorkHoursReportPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMonth);
  }

  Future<void> _loadMonth() async {
    await ref.read(reportsProvider.notifier).loadAdminWorkHoursReportByMonth(
      month: _selectedMonth,
    );
  }

  Future<void> _refresh() async => _loadMonth();

  String _fmt(int minutes) {
    if (minutes <= 0) return '0 د';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m د';
    if (m == 0) return '$h س';
    return '$h س و $m د';
  }

  String _scheduleTypeTextAr(String value) {
    switch (value) {
      case 'fixed':
        return 'دوام ثابت';
      case 'hourly':
        return 'دوام بالساعات';
      default:
        return value;
    }
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
      case 'early_leave':
        return 'خروج مبكر غير معتمد';
      case 'early_leave_partial':
        return 'خروج مبكر جزئي';
      case 'early_leave_approved':
        return 'خروج مبكر معتمد';
      case 'late_checked_out':
        return 'مكتمل مع تأخير';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final reportLang = localeCode == 'en' ? 'en' : 'ar';

    final rows = [...state.monthlyWorkHours]
      ..sort((a, b) => b.workedMinutes.compareTo(a.workedMinutes));

    final totalWorked = rows.fold<int>(0, (s, r) => s + r.workedMinutes);
    final totalOvertime = rows.fold<int>(0, (s, r) => s + r.overtimeMinutes);
    final totalRemaining = rows.fold<int>(0, (s, r) => s + r.remainingMinutes);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text('تقرير ساعات العمل الشهري'),
        actions: [
          IconButton(
            tooltip: 'PDF',
            onPressed: rows.isEmpty
                ? null
                : () async {
              final pdfRows = rows
                  .map(
                    (r) => AdminWorkHoursPdfRow(
                  employeeName: '${r.employeeName} (${r.attendanceDate})',
                  scheduleType: _scheduleTypeTextAr(r.scheduleType),
                  requiredMinutes: r.requiredMinutes,
                  workedMinutes: r.workedMinutes,
                  overtimeMinutes: r.overtimeMinutes,
                  remainingMinutes: r.remainingMinutes,
                  status: _statusTextAr(r.status),
                ),
              )
                  .toList();

              final monthLabel =
                  '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

              final bytes = await ReportsPdfService.instance.buildAdminWorkHoursReportPdf(
                rows: pdfRows,
                generatedBy: reportLang == 'en' ? 'Administration' : 'الإدارة',
                monthLabel: monthLabel,
                lang: reportLang,
              );

              if (!context.mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PdfPreviewPage(
                    bytes: bytes,
                    title: 'معاينة تقرير ساعات العمل',
                    fileName:
                    'nabd_alamal_work_hours_${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}.pdf',
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
          if (state.error != null && rows.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                state.error!,
                style: const TextStyle(
                  color: Color(0xFFDC2626),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
                  'لا توجد بيانات ساعات عمل في هذا الشهر',
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
                'المنجز: ${_fmt(totalWorked)} | الإضافي: ${_fmt(totalOvertime)} | المتبقي: ${_fmt(totalRemaining)}',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 10),
            ...rows.map((r) {
              return Container(
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
                    Text('التاريخ: ${r.attendanceDate}'),
                    Text('نوع الدوام: ${_scheduleTypeTextAr(r.scheduleType)}'),
                    Text('المطلوب: ${_fmt(r.requiredMinutes)}'),
                    Text('المنجز: ${_fmt(r.workedMinutes)}'),
                    Text('الإضافي: ${_fmt(r.overtimeMinutes)}'),
                    Text('المتبقي: ${_fmt(r.remainingMinutes)}'),
                    Text('الحالة: ${_statusTextAr(r.status)}'),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}