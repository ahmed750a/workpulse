import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../pdf/reports_pdf_service.dart';
import 'providers/reports_provider.dart';
import '../../../shared/widgets/pdf_preview_page.dart';

class AdminGeofenceReportPage extends ConsumerStatefulWidget {
  const AdminGeofenceReportPage({super.key});

  @override
  ConsumerState<AdminGeofenceReportPage> createState() =>
      _AdminGeofenceReportPageState();
}

class _AdminGeofenceReportPageState extends ConsumerState<AdminGeofenceReportPage> {
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  bool _outsideOnly = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    await ref.read(reportsProvider.notifier).loadAdminGeofenceReportByMonth(
      month: _selectedMonth,
      outsideOnly: _outsideOnly,
    );
  }

  String _t(bool isEn, String ar, String en) => isEn ? en : ar;

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

    return isEn
        ? '${monthsEn[date.month - 1]} ${date.year}'
        : '${monthsAr[date.month - 1]} ${date.year}';
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

  Widget _statusChip({
    required String text,
    required bool isOutside,
  }) {
    final bg = isOutside ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7);
    final fg = isOutside ? const Color(0xFFB91C1C) : const Color(0xFF15803D);

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

  Widget _infoLine({
    required bool isEn,
    required String label,
    required String value,
  }) {
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final rows = state.adminGeofenceMonthly;
    final outsideCount = rows.where((e) => e.isOutside).length;

    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isEn = localeCode == 'en';
    final reportLang = isEn ? 'en' : 'ar';

    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          title: const Text('تقرير الالتزام الجغرافي الشهري'),
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
                      (r) => AdminGeofencePdfRow(
                    employeeName: r.employeeName,
                    attendanceDate: r.attendanceDate,
                    status: _statusTextAr(r.status),
                    geofenceEnabled: r.geofenceEnabled,
                    distanceMeters: r.distanceMeters,
                    geofenceRadiusM: r.geofenceRadiusM,
                    isOutside: r.isOutside,
                  ),
                )
                    .toList();

                final bytes = await ReportsPdfService.instance.buildAdminGeofenceReportPdf(
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
                      title: _t(isEn, 'معاينة تقرير الالتزام الجغرافي', 'Geofence Report Preview'),
                      fileName: 'nabd_alamal_geofence_$monthLabel.pdf',
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
                      icon: Icon(isEn ? Icons.chevron_right_rounded : Icons.chevron_left_rounded),
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
                      icon: Icon(isEn ? Icons.chevron_left_rounded : Icons.chevron_right_rounded),
                      color: const Color(0xFF0F766E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                value: _outsideOnly,
                onChanged: (v) {
                  setState(() => _outsideOnly = v);
                  _load();
                },
                activeColor: const Color(0xFF0F172A),
                activeTrackColor: const Color(0xFF0F766E),
                inactiveThumbColor: const Color(0xFF94A3B8),
                inactiveTrackColor: const Color(0xFFE2E8F0),
                title: Text(_t(isEn, 'عرض خارج النطاق فقط', 'Show Outside Area Only')),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
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
                child: Text(
                  isEn
                      ? 'Total records: ${rows.length} | Outside area: $outsideCount'
                      : 'إجمالي السجلات: ${rows.length} | خارج النطاق: $outsideCount',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              if (state.isLoading && rows.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (rows.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      _t(isEn, 'لا توجد بيانات للالتزام الجغرافي لهذا الشهر', 'No geofence data for this month'),
                    ),
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
                                Row(
                                  children: isEn
                                      ? [
                                    Expanded(
                                      child: Text(
                                        'النتيجة:',
                                        textAlign: TextAlign.left,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _statusChip(
                                      text: r.isOutside ? 'خارج النطاق' : 'داخل النطاق',
                                      isOutside: r.isOutside,
                                    ),
                                  ]
                                      : [
                                    Expanded(
                                      child: Text(
                                        'النتيجة:',
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _statusChip(
                                      text: r.isOutside ? 'خارج النطاق' : 'داخل النطاق',
                                      isOutside: r.isOutside,
                                    ),
                                  ],
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
                                  children: [
                                    Expanded(
                                      child: _metaPill(
                                        icon: Icons.location_on_rounded,
                                        label: 'المسافة',
                                        value: '${r.distanceMeters?.toStringAsFixed(1) ?? '-'} م',
                                        isEn: isEn,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _metaPill(
                                        icon: Icons.radio_button_checked_rounded,
                                        label: 'نطاق السماح',
                                        value: '${r.geofenceRadiusM} م',
                                        isEn: isEn,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                _infoLine(
                                  isEn: isEn,
                                  label: 'الحالة',
                                  value: _statusTextAr(r.status),
                                ),
                                const SizedBox(height: 4),
                                _infoLine(
                                  isEn: isEn,
                                  label: 'الالتزام الجغرافي',
                                  value: r.geofenceEnabled ? 'مفعل' : 'غير مفعل',
                                ),
                                const SizedBox(height: 4),
                                _infoLine(
                                  isEn: isEn,
                                  label: 'التاريخ',
                                  value: r.attendanceDate,
                                ),
                                if ((r.locationUpdatedAt ?? '').trim().isNotEmpty) ...[
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
                                      label: 'آخر تحديث موقع',
                                      value: r.locationUpdatedAt!,
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
}