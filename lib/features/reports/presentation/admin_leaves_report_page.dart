import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/pdf_preview_page.dart';
import '../pdf/reports_pdf_service.dart';
import 'providers/reports_provider.dart';

class AdminLeavesReportPage extends ConsumerStatefulWidget {
  const AdminLeavesReportPage({super.key});

  @override
  ConsumerState<AdminLeavesReportPage> createState() => _AdminLeavesReportPageState();
}

class _AdminLeavesReportPageState extends ConsumerState<AdminLeavesReportPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  Widget _titleValueRow({
    required bool isEn,
    required String title,
    required String value,
  }) {
    return Row(
      children: isEn
          ? [
        Expanded(
          child: Text(
            '$title:',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ]
          : [
        Expanded(
          child: Text(
            '$title:',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusRow({
    required bool isEn,
    required String title,
    required String rawStatus,
    required String text,
  }) {
    return Row(
      children: isEn
          ? [
        Expanded(
          child: Text(
            '$title:',
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(
          text: text,
          rawStatus: rawStatus,
          isEn: isEn,
        ),
      ]
          : [
        Expanded(
          child: Text(
            '$title:',
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _statusChip(
          text: text,
          rawStatus: rawStatus,
          isEn: isEn,
        ),
      ],
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String label,
    required String value,
    required bool isEn,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: isEn
            ? [
          Icon(icon, size: 16, color: const Color(0xFF334155)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label:',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ]
            : [
          Icon(icon, size: 16, color: const Color(0xFF334155)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label:',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _status = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    await ref.read(reportsProvider.notifier).loadAdminLeavesReportByMonth(
      month: _selectedMonth,
      status: _status,
    );
  }

  String _monthName(DateTime date, bool isEn) {
    const monthsAr = [
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
    const monthsEn = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return isEn ? '${monthsEn[date.month - 1]} ${date.year}' : '${monthsAr[date.month - 1]} ${date.year}';
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _load();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    if (isCurrentMonth) return;

    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _load();
  }

  String _statusText(String value, bool isEn) {
    switch (value) {
      case 'pending':
        return isEn ? 'Pending' : 'معلّق';
      case 'approved':
        return isEn ? 'Approved' : 'معتمد';
      case 'rejected':
        return isEn ? 'Rejected' : 'مرفوض';
      case 'cancelled':
        return isEn ? 'Cancelled' : 'ملغي';
      default:
        return value;
    }
  }

  String _t(bool isEn, String ar, String en) => isEn ? en : ar;

  Widget _statusChip({
    required String text,
    required String rawStatus,
    required bool isEn,
  }) {
    final status = rawStatus.toLowerCase();
    Color bg = const Color(0xFFE2E8F0);
    Color fg = const Color(0xFF475569);

    if (status == 'approved') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'pending') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFD97706);
    } else if (status == 'rejected') {
      bg = const Color(0xFFFEE2E2);
      fg = const Color(0xFFB91C1C);
    } else if (status == 'cancelled') {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _infoLine({
    required bool isEn,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: isEn
            ? [
          Expanded(
            child: Text(
              '$label:',
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ]
            : [
          Expanded(
            child: Text(
              '$label:',
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final rows = state.adminLeavesMonthly;

    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isEn = localeCode == 'en';
    final reportLang = isEn ? 'en' : 'ar';

    final approvedCount = rows.where((e) => e.status == 'approved').length;
    final pendingCount = rows.where((e) => e.status == 'pending').length;
    final rejectedCount = rows.where((e) => e.status == 'rejected').length;
    final totalDays = rows.fold<double>(0, (s, e) => s + e.totalDays);

    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          title: const Text('تقرير الإجازات الشهري'),
          actions: [
            IconButton(
              tooltip: 'PDF',
              onPressed: rows.isEmpty
                  ? null
                  : () async {
                final monthLabel =
                    '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';

                final pdfRows = rows
                    .map(
                      (e) => AdminLeavesReportPdfRow(
                    employeeName: e.employeeName,
                    leaveTypeName: e.leaveTypeName,
                    startDate: e.startDate,
                    endDate: e.endDate,
                    totalDays: e.totalDays,
                    status: _statusText(e.status, isEn),
                    reason: e.reason ?? '',
                  ),
                )
                    .toList();

                final bytes = await ReportsPdfService.instance.buildAdminLeavesReportPdf(
                  rows: pdfRows,
                  generatedBy: isEn ? 'Administration' : 'الإدارة',
                  monthLabel: monthLabel,
                  lang: reportLang,
                );

                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewPage(
                      bytes: bytes,
                      title: _t(isEn, 'معاينة تقرير الإجازات', 'Leaves Report Preview'),
                      fileName:
                      'nabd_alamal_leaves_${_selectedMonth.year}_${_selectedMonth.month.toString().padLeft(2, '0')}.pdf',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
            ),
            IconButton(
              tooltip: _t(isEn, 'تحديث', 'Refresh'),
              onPressed: state.isLoading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
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
                      icon: Icon(
                        isEn ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                      ),
                      color: const Color(0xFF0F766E),
                    ),
                    Expanded(
                      child: Text(
                        _monthName(_selectedMonth, isEn),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: Icon(
                        isEn ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                      ),
                      color: const Color(0xFF0F766E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: InputDecoration(
                    labelText: 'فلتر الحالة',                    border: const OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(_t(isEn, 'الكل', 'All'))),
                    DropdownMenuItem(value: 'pending', child: Text(_statusText('pending', isEn))),
                    DropdownMenuItem(value: 'approved', child: Text(_statusText('approved', isEn))),
                    DropdownMenuItem(value: 'rejected', child: Text(_statusText('rejected', isEn))),
                    DropdownMenuItem(value: 'cancelled', child: Text(_statusText('cancelled', isEn))),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _status = v);
                    _load();
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _kpi('الطلبات', '${rows.length}', const Color(0xFF1E3A8A))),
                  const SizedBox(width: 8),
                  Expanded(child: _kpi('إجمالي الأيام', totalDays.toStringAsFixed(1), const Color(0xFF1D4ED8))),
                  const SizedBox(width: 8),
                  Expanded(child: _kpi('معتمد', '$approvedCount', const Color(0xFF15803D))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _kpi('معلّق', '$pendingCount', const Color(0xFFD97706))),
                  const SizedBox(width: 8),
                  Expanded(child: _kpi('مرفوض', '$rejectedCount', const Color(0xFFB91C1C))),
                ],
              ),
              const SizedBox(height: 12),
              if (state.isLoading && rows.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (state.error != null && rows.isEmpty)
                Center(
                  child: Text(
                    state.error!,
                    style: const TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700),
                  ),
                )
              else if (rows.isEmpty)
                  Center(
                    child: Text(
                      _t(isEn, 'لا توجد طلبات إجازة في هذا الشهر', 'No leave requests found for this month'),
                      style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
                    ),
                  )
                else
                  ...rows.map(
                        (r) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: const BoxDecoration(
                                color: Color(0xFFF8FAFC),
                                border: Border(
                                  bottom: BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                              ),
                              child: Column(
                                children: [
                                  _titleValueRow(
                                    isEn: isEn,
                                    title: 'الاسم',
                                    value: r.employeeName,
                                  ),
                                  const SizedBox(height: 8),
                                  _statusRow(
                                    isEn: isEn,
                                    title: 'الاعتمادية',
                                    rawStatus: r.status,
                                    text: _statusText(r.status, isEn),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment:
                                isEn ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: isEn
                                        ? [
                                      Expanded(
                                        child: _metaPill(
                                          icon: Icons.category_rounded,
                                          label: 'النوع',
                                          value: r.leaveTypeName,
                                          isEn: isEn,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _metaPill(
                                          icon: Icons.timelapse_rounded,
                                          label: 'الأيام',
                                          value: r.totalDays.toStringAsFixed(1),
                                          isEn: isEn,
                                        ),
                                      ),
                                    ]
                                        : [
                                      Expanded(
                                        child: _metaPill(
                                          icon: Icons.category_rounded,
                                          label: 'النوع',
                                          value: r.leaveTypeName,
                                          isEn: isEn,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _metaPill(
                                          icon: Icons.timelapse_rounded,
                                          label: 'الأيام',
                                          value: r.totalDays.toStringAsFixed(1),
                                          isEn: isEn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _infoLine(
                                    isEn: isEn,
                                    label: 'الفترة',
                                    value: '${r.startDate} إلى ${r.endDate}',
                                  ),
                                  if ((r.reason ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: _infoLine(
                                        isEn: isEn,
                                        label: 'السبب',
                                        value: r.reason!,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kpi(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}