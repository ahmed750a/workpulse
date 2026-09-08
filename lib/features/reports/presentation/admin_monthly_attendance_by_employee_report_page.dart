import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workpulse/features/attendance/data/models/attendance_record_model.dart';
import 'package:workpulse/features/attendance/presentation/providers/attendance_provider.dart';
import 'package:workpulse/features/employees/presentation/providers/employees_provider.dart';
import 'package:workpulse/features/reports/pdf/reports_pdf_service.dart';
import 'package:workpulse/shared/widgets/pdf_preview_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
class AdminMonthlyAttendanceByEmployeeReportPage extends ConsumerStatefulWidget {
  const AdminMonthlyAttendanceByEmployeeReportPage({super.key});

  @override
  ConsumerState<AdminMonthlyAttendanceByEmployeeReportPage> createState() =>
      _AdminMonthlyAttendanceByEmployeeReportPageState();
}

class _AdminMonthlyAttendanceByEmployeeReportPageState
    extends ConsumerState<AdminMonthlyAttendanceByEmployeeReportPage> {
  String? _selectedEmployeeId;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(employeesProvider.notifier).loadEmployees();
      _tryAutoSelectEmployee();
      await _loadReport();
    });
  }

  String _t(bool isEn, String ar, String en) => isEn ? en : ar;
  Future<String> _uploadPdfReport({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final client = Supabase.instance.client;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'monthly_attendance/$timestamp-$fileName';

    await client.storage.from('reports').uploadBinary(
      storagePath,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'application/pdf',
        upsert: true,
      ),
    );

    final publicUrl = client.storage.from('reports').getPublicUrl(storagePath);
    return publicUrl;
  }
  void _tryAutoSelectEmployee() {
    final employees = ref.read(employeesProvider).employees
        .where((e) => (e.role ?? 'employee') == 'employee')
        .toList();

    if (_selectedEmployeeId == null && employees.isNotEmpty) {
      _selectedEmployeeId = employees.first.id;
    }
  }

  Future<void> _loadReport() async {
    if (_selectedEmployeeId == null) return;
    await ref.read(attendanceProvider.notifier).loadAdminEmployeeMonthlyRecords(
      employeeId: _selectedEmployeeId!,
      month: _selectedMonth,
    );
  }

  void _prevMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1, 1);
    });
    _loadReport();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;
    if (isCurrentMonth) return;

    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 1);
    });
    _loadReport();
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

  String _statusText(String status, bool isEn) {
    switch (status) {
      case 'checked_in':
        return _t(isEn, 'داخل الدوام', 'Checked In');
      case 'checked_out':
        return _t(isEn, 'مكتمل', 'Completed');
      case 'late':
        return _t(isEn, 'تأخير غير معتمد', 'Unapproved Late');
      case 'approved_late':
        return _t(isEn, 'تأخير معتمد', 'Approved Late');
      case 'partially_approved_late':
        return _t(isEn, 'تأخير جزئي', 'Partial Late');
      case 'early_leave':
        return _t(isEn, 'خروج مبكر غير معتمد', 'Unapproved Early Leave');
      case 'early_leave_partial':
        return _t(isEn, 'خروج مبكر جزئي', 'Partial Early Leave');
      case 'early_leave_approved':
        return _t(isEn, 'خروج مبكر معتمد', 'Approved Early Leave');
      case 'late_checked_out':
        return _t(isEn, 'مكتمل مع تأخير', 'Completed with Late');
      case 'hours_incomplete':
        return _t(isEn, 'ساعات ناقصة', 'Incomplete Hours');
      case 'hours_completed':
        return _t(isEn, 'ساعات مكتملة', 'Hours Completed');
      case 'hours_completed_with_overtime':
        return _t(isEn, 'ساعات مكتملة مع إضافي', 'Completed with Overtime');
      default:
        return status;
    }
  }

  String _fmtMinutes(int minutes, bool isEn) {
    if (minutes <= 0) return isEn ? '0 min' : '0 د';
    final h = minutes ~/ 60;
    final m = minutes % 60;

    if (isEn) {
      if (h == 0) return '$m min';
      if (m == 0) return '$h hr';
      return '$h hr $m min';
    }

    if (h == 0) return '$m د';
    if (m == 0) return '$h س';
    return '$h س و $m د';
  }

  Map<String, int> _stats(List<AttendanceRecordModel> records) {
    int present = 0;
    int late = 0;
    int early = 0;
    int worked = 0;

    for (final r in records) {
      if (r.checkInAt != null && r.checkOutAt != null) present++;
      if (r.unapprovedLateMinutes > 0) late++;
      if (r.unapprovedEarlyLeaveMinutes > 0) early++;
      worked += r.workedMinutes;
    }

    return {
      'present': present,
      'late': late,
      'early': early,
      'worked': worked,
    };
  }

  @override
  Widget build(BuildContext context) {
    final employeesState = ref.watch(employeesProvider);
    final attendanceState = ref.watch(attendanceProvider);

    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isEn = localeCode == 'en';
    final reportLang = isEn ? 'en' : 'ar';

    final employees = employeesState.employees
        .where((e) => (e.role ?? 'employee') == 'employee')
        .toList();

    final selectedEmployee = employees.where((e) => e.id == _selectedEmployeeId).isNotEmpty
        ? employees.firstWhere((e) => e.id == _selectedEmployeeId)
        : null;

    final records = attendanceState.adminEmployeeRecords;
    final stats = _stats(records);

    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0B1B3B),
          foregroundColor: Colors.white,
          title: Text(
            _t(isEn, 'تقرير الحضور الشهري حسب الموظف', 'Monthly Attendance by Employee'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              tooltip: 'PDF',
              onPressed: () async {
                try {
                  if (selectedEmployee == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_t(isEn, 'اختر موظف أولاً', 'Please select an employee first'))),
                    );
                    return;
                  }

                  if (records.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_t(isEn, 'لا توجد بيانات للتصدير', 'No data to export'))),
                    );
                    return;
                  }

                  final monthLabel =
                      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}';
                  final fileName =
                      'nabd_alamal_monthly_attendance_${selectedEmployee.id}_$monthLabel.pdf';

                  final pdfRows = records
                      .map(
                        (r) => AdminMonthlyEmployeeAttendancePdfRow(
                      attendanceDate: r.attendanceDate,
                      status: _statusText(r.status, isEn),
                      workedMinutes: r.workedMinutes,
                      unapprovedLateMinutes: r.unapprovedLateMinutes,
                      unapprovedEarlyLeaveMinutes: r.unapprovedEarlyLeaveMinutes,
                    ),
                  )
                      .toList();

                  final bytes = await ReportsPdfService.instance
                      .buildAdminMonthlyAttendanceByEmployeePdf(
                    employeeName: selectedEmployee.fullName,
                    rows: pdfRows,
                    generatedBy: isEn ? 'Administration' : 'الإدارة',
                    monthLabel: monthLabel,
                    lang: reportLang,
                  );

                  if (!context.mounted) return;

                  // 1) افتح المعاينة أولًا (حتى المستخدم يشوف نتيجة الضغط فورًا)
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PdfPreviewPage(
                        bytes: bytes,
                        title: _t(isEn, 'معاينة تقرير الحضور الشهري', 'Monthly Attendance Preview'),
                        fileName: fileName,
                      ),
                    ),
                  );

                  // 2) ارفع الملف (اختياري بعد المعاينة)
                  final publicUrl = await _uploadPdfReport(
                    bytes: bytes,
                    fileName: fileName,
                  );

                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _t(isEn, 'تم رفع التقرير بنجاح', 'Report uploaded successfully'),
                      ),
                    ),
                  );

                  debugPrint('PDF URL: $publicUrl');
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${_t(isEn, 'فشل التصدير', 'Export failed')}: $e')),
                  );
                  debugPrint('PDF ERROR: $e');
                }
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
            ),
            IconButton(
              tooltip: _t(isEn, 'تحديث', 'Refresh'),
              onPressed: attendanceState.isLoading ? null : _loadReport,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: employeesState.isLoading && employees.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(14),
          children: [
            _SectionCard(
              child: DropdownButtonFormField<String>(
                value: _selectedEmployeeId,
                decoration: InputDecoration(
                  labelText: _t(isEn, 'اختر الموظف', 'Select Employee'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: employees
                    .map(
                      (e) => DropdownMenuItem<String>(
                    value: e.id,
                    child: Text(e.fullName),
                  ),
                )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedEmployeeId = v);
                  _loadReport();
                },
              ),
            ),
            const SizedBox(height: 12),

            _SectionCard(
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: _prevMonth,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0B1B3B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_t(isEn, 'السابق', 'Previous')),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B1B3B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedMonth,
                          firstDate: DateTime(2020, 1, 1),
                          lastDate: DateTime.now(),
                          helpText: _t(isEn, 'اختر الشهر', 'Select month'),
                        );
                        if (picked == null) return;
                        setState(() {
                          _selectedMonth = DateTime(picked.year, picked.month, 1);
                        });
                        _loadReport();
                      },
                      child: Text(_monthName(_selectedMonth, isEn)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: _nextMonth,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0B1B3B)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(_t(isEn, 'التالي', 'Next')),
                  ),
                ],
              ),
            ),

            if (selectedEmployee != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B1B3B), Color(0xFF102A5C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${_t(isEn, 'الموظف', 'Employee')}: ${selectedEmployee.fullName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                  textAlign: isEn ? TextAlign.left : TextAlign.right,
                ),
              ),
            ],

            const SizedBox(height: 12),

            _StatFullWidthTile(
              label: _t(isEn, 'أيام مكتملة', 'Completed Days'),
              value: '${stats['present']}',
              color: const Color(0xFF0B1B3B),
            ),
            const SizedBox(height: 8),
            _StatFullWidthTile(
              label: _t(isEn, 'أيام تأخير', 'Late Days'),
              value: '${stats['late']}',
              color: const Color(0xFFB91C1C),
            ),
            const SizedBox(height: 8),
            _StatFullWidthTile(
              label: _t(isEn, 'خروج مبكر', 'Early Leave Days'),
              value: '${stats['early']}',
              color: const Color(0xFFD97706),
            ),
            const SizedBox(height: 8),
            _StatFullWidthTile(
              label: _t(isEn, 'إجمالي العمل', 'Total Worked Time'),
              value: _fmtMinutes(stats['worked'] ?? 0, isEn),
              color: const Color(0xFF1D4ED8),
            ),

            const SizedBox(height: 14),

            if (attendanceState.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (records.isEmpty)
              _SectionCard(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Text(
                    _t(isEn, 'لا توجد سجلات لهذا الشهر', 'No records for this month'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              ...records.map((r) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0B1B3B).withValues(alpha: 0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 5,
                        height: 116,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0B1B3B),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // التاريخ يسار
                              Row(
                                children: [
                                  Text(
                                    r.attendanceDate,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                      color: Color(0xFF0F172A),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),

                              const SizedBox(height: 8),

                              // باقي النص يمين
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'الحالة: ${_statusText(r.status, isEn)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'العمل: ${_fmtMinutes(r.workedMinutes, isEn)}',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFF334155),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'تأخير غير معتمد: ${r.unapprovedLateMinutes} دقيقة',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFFB91C1C),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'خروج مبكر غير معتمد: ${r.unapprovedEarlyLeaveMinutes} دقيقة',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    color: Color(0xFFD97706),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1B3B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class _StatFullWidthTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatFullWidthTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isEn = Directionality.of(context) == TextDirection.ltr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: isEn
            ? [
          Container(
            width: 7,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ]
            : [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 7,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isEn;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isEn,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: isEn
          ? [
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
      ]
          : [
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          ': $label',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}