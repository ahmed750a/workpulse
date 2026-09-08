import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart' hide PdfDocument;
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' hide PdfColor;

import '../data/models/admin_today_summary_model.dart';

enum ReportPdfLang { ar, en }

ReportPdfLang reportPdfLangFromCode(String? code) {
  return (code ?? '').toLowerCase() == 'en' ? ReportPdfLang.en : ReportPdfLang.ar;
}

class AdminCorrectionPdfRow {
  final String employeeName;
  final String correctionDate;
  final String type;
  final String requestedTime;
  final String status;
  final String reason;
  final String rejectionReason;

  const AdminCorrectionPdfRow({
    required this.employeeName,
    required this.correctionDate,
    required this.type,
    required this.requestedTime,
    required this.status,
    required this.reason,
    required this.rejectionReason,
  });
}

class AdminGeofencePdfRow {
  final String employeeName;
  final String attendanceDate;
  final String status;
  final bool geofenceEnabled;
  final double? distanceMeters;
  final int geofenceRadiusM;
  final bool isOutside;

  const AdminGeofencePdfRow({
    required this.employeeName,
    required this.attendanceDate,
    required this.status,
    required this.geofenceEnabled,
    required this.distanceMeters,
    required this.geofenceRadiusM,
    required this.isOutside,
  });
}

class AdminEarlyLeaveReportPdfRow {
  final String employeeName;
  final int approvedMinutes;
  final int unapprovedMinutes;
  final String status;

  const AdminEarlyLeaveReportPdfRow({
    required this.employeeName,
    required this.approvedMinutes,
    required this.unapprovedMinutes,
    required this.status,
  });

  int get totalMinutes => approvedMinutes + unapprovedMinutes;
}

class AdminLateReportPdfRow {
  final String employeeName;
  final int approvedMinutes;
  final int unapprovedMinutes;
  final String status;

  const AdminLateReportPdfRow({
    required this.employeeName,
    required this.approvedMinutes,
    required this.unapprovedMinutes,
    required this.status,
  });

  int get totalMinutes => approvedMinutes + unapprovedMinutes;
}

class AdminWorkHoursPdfRow {
  final String employeeName;
  final String scheduleType;
  final int requiredMinutes;
  final int workedMinutes;
  final int overtimeMinutes;
  final int remainingMinutes;
  final String status;

  const AdminWorkHoursPdfRow({
    required this.employeeName,
    required this.scheduleType,
    required this.requiredMinutes,
    required this.workedMinutes,
    required this.overtimeMinutes,
    required this.remainingMinutes,
    required this.status,
  });
}

class AdminPermissionsReportPdfRow {
  final String employeeName;
  final String permissionDate;
  final String type;
  final String status;
  final int totalMinutes;
  final String reason;

  const AdminPermissionsReportPdfRow({
    required this.employeeName,
    required this.permissionDate,
    required this.type,
    required this.status,
    required this.totalMinutes,
    required this.reason,
  });
}

class AdminLeavesReportPdfRow {
  final String employeeName;
  final String leaveTypeName;
  final String startDate;
  final String endDate;
  final double totalDays;
  final String status;
  final String reason;

  const AdminLeavesReportPdfRow({
    required this.employeeName,
    required this.leaveTypeName,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.status,
    required this.reason,
  });
}

class AdminViolationPdfRow {
  final String employeeName;
  final String attendanceDate;
  final String status;
  final int unapprovedLateMinutes;
  final int unapprovedEarlyLeaveMinutes;
  final int workedMinutes;

  const AdminViolationPdfRow({
    required this.employeeName,
    required this.attendanceDate,
    required this.status,
    required this.unapprovedLateMinutes,
    required this.unapprovedEarlyLeaveMinutes,
    required this.workedMinutes,
  });

  int get totalViolationMinutes =>
      unapprovedLateMinutes + unapprovedEarlyLeaveMinutes;
}

class AdminMonthlyEmployeeAttendancePdfRow {
  final String attendanceDate;
  final String status;
  final int workedMinutes;
  final int unapprovedLateMinutes;
  final int unapprovedEarlyLeaveMinutes;

  const AdminMonthlyEmployeeAttendancePdfRow({
    required this.attendanceDate,
    required this.status,
    required this.workedMinutes,
    required this.unapprovedLateMinutes,
    required this.unapprovedEarlyLeaveMinutes,
  });
}

class ReportsPdfService {
  ReportsPdfService._();
  static final ReportsPdfService instance = ReportsPdfService._();

  pw.Font? _fontArabic;
  pw.Font? _fontFallback;
  Uint8List? _fontArabicBytes;

  pw.Widget _tableCell({
    required String text,
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    bool isHeader = false,
    bool isValue = false,
  }) {
    final align = isValue
        ? pw.TextAlign.center
        : (lang == ReportPdfLang.ar ? pw.TextAlign.right : pw.TextAlign.left);

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: pw.Align(
        alignment: isValue
            ? pw.Alignment.center
            : (lang == ReportPdfLang.ar ? pw.Alignment.centerRight : pw.Alignment.centerLeft),
        child: pw.Text(
          _safe(text),
          textAlign: align,
          textDirection: lang == ReportPdfLang.ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          style: pw.TextStyle(
            font: fonts.arabic,
            fontFallback: [fonts.fallback],
            fontSize: isHeader ? 10.5 : 10,
            color: isHeader ? PdfColors.blueGrey900 : PdfColors.black,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ),
    );
  }

  pw.Widget _dailySummaryTable({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required AdminTodaySummaryModel summary,
  }) {
    final rows = <Map<String, String>>[
      {
        'metric': _tr(lang, 'إجمالي الموظفين', 'Total Employees'),
        'value': summary.totalEmployees.toString(),
      },
      {
        'metric': _tr(lang, 'داخل الدوام الآن', 'Currently Checked In'),
        'value': summary.checkedInNow.toString(),
      },
      {
        'metric': _tr(lang, 'أكملوا الدوام', 'Completed Today'),
        'value': summary.completedToday.toString(),
      },
      {
        'metric': _tr(lang, 'تأخير اليوم', 'Late Today'),
        'value': summary.lateToday.toString(),
      },
      {
        'metric': _tr(lang, 'إجازة معتمدة', 'On Approved Leave'),
        'value': summary.onApprovedLeaveToday.toString(),
      },
    ];

    final isAr = lang == ReportPdfLang.ar;

    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 6),
      child: pw.Table(
        border: pw.TableBorder.all(
          color: PdfColors.grey400,
          width: 0.7,
        ),
        columnWidths: const {
          0: pw.FlexColumnWidth(2),
          1: pw.FlexColumnWidth(3),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.blueGrey50),
            children: isAr
                ? [
              _tableCell(
                text: _tr(lang, 'القيمة', 'Value'),
                fonts: fonts,
                lang: lang,
                isHeader: true,
                isValue: true,
              ),
              _tableCell(
                text: _tr(lang, 'المؤشر', 'Metric'),
                fonts: fonts,
                lang: lang,
                isHeader: true,
              ),
            ]
                : [
              _tableCell(
                text: _tr(lang, 'المؤشر', 'Metric'),
                fonts: fonts,
                lang: lang,
                isHeader: true,
              ),
              _tableCell(
                text: _tr(lang, 'القيمة', 'Value'),
                fonts: fonts,
                lang: lang,
                isHeader: true,
                isValue: true,
              ),
            ],
          ),
          ...rows.map(
                (r) => pw.TableRow(
              children: isAr
                  ? [
                _tableCell(
                  text: _digits(r['value'] ?? '0', lang),
                  fonts: fonts,
                  lang: lang,
                  isValue: true,
                ),
                _tableCell(
                  text: r['metric'] ?? '',
                  fonts: fonts,
                  lang: lang,
                ),
              ]
                  : [
                _tableCell(
                  text: r['metric'] ?? '',
                  fonts: fonts,
                  lang: lang,
                ),
                _tableCell(
                  text: _digits(r['value'] ?? '0', lang),
                  fonts: fonts,
                  lang: lang,
                  isValue: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> addSignatureToPdf({
    required Uint8List originalPdfBytes,
    required Uint8List signaturePngBytes,
    String? signerName,
    String? signedAtText,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final document = PdfDocument(inputBytes: originalPdfBytes);

    try {
      if (document.pages.count == 0) return originalPdfBytes;

      final page = document.pages[document.pages.count - 1];
      final graphics = page.graphics;
      final font = PdfTrueTypeFont(await _loadArabicFontBytes(), 10);
      final image = PdfBitmap(signaturePngBytes);

      const margin = 24.0;
      const imageW = 140.0;
      const imageH = 56.0;
      final size = page.getClientSize();

      final x = l == ReportPdfLang.ar ? size.width - imageW - margin : margin;
      final y = size.height - imageH - 72;

      final signer = _safeGeneratorName(signerName, l);
      final signedAt = _safe(signedAtText ?? _dateTimeWords(l));

      final signedByText = l == ReportPdfLang.ar ? 'توقيع $signer' : 'Signed by $signer';
      final signedAtTextFinal = l == ReportPdfLang.ar ? 'وقت التوقيع $signedAt' : 'Signed at $signedAt';

      graphics.drawString(
        signedByText,
        font,
        bounds: Rect.fromLTWH(x, y - 28, 260, 14),
        format: PdfStringFormat(
          textDirection: l == ReportPdfLang.ar
              ? PdfTextDirection.rightToLeft
              : PdfTextDirection.leftToRight,
          alignment:
          l == ReportPdfLang.ar ? PdfTextAlignment.right : PdfTextAlignment.left,
        ),
      );

      graphics.drawString(
        signedAtTextFinal,
        font,
        bounds: Rect.fromLTWH(x, y - 14, 260, 14),
        format: PdfStringFormat(
          textDirection: l == ReportPdfLang.ar
              ? PdfTextDirection.rightToLeft
              : PdfTextDirection.leftToRight,
          alignment:
          l == ReportPdfLang.ar ? PdfTextAlignment.right : PdfTextAlignment.left,
        ),
      );

      graphics.drawImage(image, Rect.fromLTWH(x, y, imageW, imageH));
      return Uint8List.fromList(document.saveSync());
    } finally {
      document.dispose();
    }
  }

  Future<Uint8List> buildAdminDailyAttendanceSummaryPdf({
    required AdminTodaySummaryModel summary,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير ملخص الحضور اليومي',
        titleEn: 'Daily Attendance Summary Report',
        subtitleAr: 'جدول تفصيلي للمؤشرات اليومية',
        subtitleEn: 'Detailed daily KPIs table',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _dailySummaryTable(
            fonts: fonts,
            lang: l,
            summary: summary,
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminViolationsReportPdf({
    required List<AdminViolationPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();
    final total = rows.fold<int>(0, (s, e) => s + e.totalViolationMinutes);

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير المخالفات',
        titleEn: 'Violations Report',
        subtitleAr: 'تأخير وخروج مبكر غير معتمد',
        subtitleEn: 'Unapproved Late & Early Leave',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد المخالفات', 'Total Violations'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          _kpi(_tr(l, 'إجمالي دقائق المخالفات', 'Total Violation Minutes'),
              '$total', fonts, PdfColors.red700, l),
          pw.SizedBox(height: 8),
          ...rows.map(
                (r) => _record(
              fonts: fonts,
              lang: l,
              title: r.employeeName,
              lines: [
                _pair(l, 'التاريخ', 'Date', r.attendanceDate),
                _pair(l, 'الحالة', 'Status', r.status),
                _pair(l, 'تأخير غير معتمد', 'Unapproved Late',
                    '${r.unapprovedLateMinutes} ${_tr(l, 'دقيقة', 'min')}'),
                _pair(l, 'خروج مبكر غير معتمد', 'Unapproved Early Leave',
                    '${r.unapprovedEarlyLeaveMinutes} ${_tr(l, 'دقيقة', 'min')}'),
                _pair(l, 'إجمالي المخالفة', 'Total Violation',
                    '${r.totalViolationMinutes} ${_tr(l, 'دقيقة', 'min')}'),
                _pair(l, 'ساعات العمل', 'Worked Hours', _fmtMinutes(r.workedMinutes, l)),
              ],
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminWorkHoursReportPdf({
    required List<AdminWorkHoursPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير ساعات العمل الشهري',
        titleEn: 'Monthly Work Hours Report',
        subtitleAr: 'المطلوب والمنجز والإضافي',
        subtitleEn: 'Required, Worked and Overtime',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد السجلات', 'Total Records'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'نوع الدوام', 'Schedule Type', r.scheduleType),
              _pair(l, 'المطلوب', 'Required',
                  _fmtMinutes(r.requiredMinutes, l)),
              _pair(l, 'المنجز', 'Worked',
                  _fmtMinutes(r.workedMinutes, l)),
              _pair(l, 'الإضافي', 'Overtime',
                  _fmtMinutes(r.overtimeMinutes, l)),
              _pair(l, 'المتبقي', 'Remaining',
                  _fmtMinutes(r.remainingMinutes, l)),
              _pair(l, 'الحالة', 'Status', r.status),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminLateReportPdf({
    required List<AdminLateReportPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    final approved = rows.fold<int>(0, (s, e) => s + e.approvedMinutes);
    final unapproved = rows.fold<int>(0, (s, e) => s + e.unapprovedMinutes);

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير التأخير الشهري',
        titleEn: 'Monthly Late Arrival Report',
        subtitleAr: 'معتمد وغير معتمد',
        subtitleEn: 'Approved and Unapproved',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الحالات', 'Total Cases'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          _kpi(_tr(l, 'المعتمد', 'Approved'),
              '$approved ${_tr(l, 'دقيقة', 'min')}', fonts, PdfColors.green700, l),
          _kpi(_tr(l, 'غير المعتمد', 'Unapproved'),
              '$unapproved ${_tr(l, 'دقيقة', 'min')}', fonts, PdfColors.red700, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'معتمد', 'Approved',
                  '${r.approvedMinutes} ${_tr(l, 'دقيقة', 'min')}'),
              _pair(l, 'غير معتمد', 'Unapproved',
                  '${r.unapprovedMinutes} ${_tr(l, 'دقيقة', 'min')}'),
              _pair(l, 'الإجمالي', 'Total',
                  '${r.totalMinutes} ${_tr(l, 'دقيقة', 'min')}'),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminEarlyLeaveReportPdf({
    required List<AdminEarlyLeaveReportPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    final approved = rows.fold<int>(0, (s, e) => s + e.approvedMinutes);
    final unapproved = rows.fold<int>(0, (s, e) => s + e.unapprovedMinutes);

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير الخروج المبكر الشهري',
        titleEn: 'Monthly Early Leave Report',
        subtitleAr: 'معتمد وغير معتمد',
        subtitleEn: 'Approved and Unapproved',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الحالات', 'Total Cases'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          _kpi(_tr(l, 'المعتمد', 'Approved'),
              '$approved ${_tr(l, 'دقيقة', 'min')}', fonts, PdfColors.green700, l),
          _kpi(_tr(l, 'غير المعتمد', 'Unapproved'),
              '$unapproved ${_tr(l, 'دقيقة', 'min')}', fonts, PdfColors.red700, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'معتمد', 'Approved',
                  '${r.approvedMinutes} ${_tr(l, 'دقيقة', 'min')}'),
              _pair(l, 'غير معتمد', 'Unapproved',
                  '${r.unapprovedMinutes} ${_tr(l, 'دقيقة', 'min')}'),
              _pair(l, 'الإجمالي', 'Total',
                  '${r.totalMinutes} ${_tr(l, 'دقيقة', 'min')}'),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminLeavesReportPdf({
    required List<AdminLeavesReportPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير الإجازات الشهري',
        titleEn: 'Monthly Leaves Report',
        subtitleAr: 'الاستهلاك والتفاصيل',
        subtitleEn: 'Consumption and Details',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الطلبات', 'Total Requests'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'نوع الإجازة', 'Leave Type', r.leaveTypeName),
              _pair(l, 'الفترة', 'Period',
                  '${r.startDate} ${_tr(l, 'إلى', 'to')} ${r.endDate}'),
              _pair(l, 'عدد الأيام', 'Total Days',
                  r.totalDays.toStringAsFixed(1)),
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'السبب', 'Reason', r.reason),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminPermissionsReportPdf({
    required List<AdminPermissionsReportPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير الأذونات الشهري',
        titleEn: 'Monthly Permissions Report',
        subtitleAr: 'الحالات والمدة',
        subtitleEn: 'Statuses and Durations',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الطلبات', 'Total Requests'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'التاريخ', 'Date', r.permissionDate),
              _pair(l, 'النوع', 'Type', r.type),
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'المدة', 'Duration',
                  '${r.totalMinutes} ${_tr(l, 'دقيقة', 'min')}'),
              _pair(l, 'السبب', 'Reason', r.reason),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminCorrectionsReportPdf({
    required List<AdminCorrectionPdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير تعديلات البصمة الشهري',
        titleEn: 'Monthly Attendance Corrections Report',
        subtitleAr: 'طلبات اعتماد ورفض',
        subtitleEn: 'Approval and Rejection Requests',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الطلبات', 'Total Requests'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'التاريخ', 'Date', r.correctionDate),
              _pair(l, 'النوع', 'Type', r.type),
              _pair(l, 'الوقت المطلوب', 'Requested Time', r.requestedTime),
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'السبب', 'Reason', r.reason),
              if (r.rejectionReason.trim().isNotEmpty)
                _pair(l, 'سبب الرفض', 'Rejection Reason', r.rejectionReason),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminGeofenceReportPdf({
    required List<AdminGeofencePdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();

    final outsideCount = rows.where((e) => e.isOutside).length;

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير الالتزام الجغرافي الشهري',
        titleEn: 'Monthly Geofence Compliance Report',
        subtitleAr: 'داخل وخارج النطاق',
        subtitleEn: 'Inside and Outside Geofence',
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد السجلات', 'Total Records'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          _kpi(_tr(l, 'خارج النطاق', 'Outside Geofence'),
              '$outsideCount', fonts, PdfColors.red700, l),
          pw.SizedBox(height: 8),
          ...rows.map((r) => _record(
            fonts: fonts,
            lang: l,
            title: r.employeeName,
            lines: [
              _pair(l, 'التاريخ', 'Date', r.attendanceDate),
              _pair(l, 'الحالة', 'Status', r.status),
              _pair(l, 'الجيوفينس', 'Geofence',
                  r.geofenceEnabled ? _tr(l, 'مفعل', 'Enabled') : _tr(l, 'غير مفعل', 'Disabled')),
              _pair(l, 'المسافة', 'Distance',
                  '${r.distanceMeters?.toStringAsFixed(1) ?? '0'} ${_tr(l, 'متر', 'm')}'),
              _pair(l, 'نطاق السماح', 'Allowed Radius',
                  '${r.geofenceRadiusM} ${_tr(l, 'متر', 'm')}'),
              _pair(l, 'النتيجة', 'Result',
                  r.isOutside ? _tr(l, 'خارج النطاق', 'Outside') : _tr(l, 'داخل النطاق', 'Inside')),
            ],
          )),
        ],
      ),
    );

    return doc.save();
  }

  Future<Uint8List> buildAdminMonthlyAttendanceByEmployeePdf({
    required String employeeName,
    required List<AdminMonthlyEmployeeAttendancePdfRow> rows,
    required String generatedBy,
    String? monthLabel,
    String lang = 'ar',
  }) async {
    final l = reportPdfLangFromCode(lang);
    final fonts = await _fonts();
    final doc = pw.Document();
    final worked = rows.fold<int>(0, (s, e) => s + e.workedMinutes);

    doc.addPage(
      _page(
        fonts: fonts,
        lang: l,
        titleAr: 'تقرير الحضور الشهري حسب الموظف',
        titleEn: 'Monthly Attendance by Employee',
        subtitleAr: employeeName,
        subtitleEn: employeeName,
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        build: [
          _kpi(_tr(l, 'عدد الأيام المسجلة', 'Recorded Days'),
              '${rows.length}', fonts, PdfColors.blue900, l),
          _kpi(_tr(l, 'إجمالي ساعات العمل', 'Total Worked Time'),
              _fmtMinutes(worked, l), fonts, PdfColors.blue700, l),
          pw.SizedBox(height: 8),
          ...rows.map(
                (r) => _monthlyAttendanceDayCardFullWidth(
              fonts: fonts,
              lang: l,
              row: r,
            ),
          ),
        ],
      ),
    );

    return doc.save();
  }

  pw.MultiPage _page({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required String titleAr,
    required String titleEn,
    required String subtitleAr,
    required String subtitleEn,
    required String generatedBy,
    required List<pw.Widget> build,
    String? monthLabel,
  }) {
    return pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(24, 20, 24, 22),
      textDirection:
      lang == ReportPdfLang.ar ? pw.TextDirection.rtl : pw.TextDirection.ltr,
      theme: pw.ThemeData.withFont(
        base: fonts.arabic,
        bold: fonts.arabic,
        italic: fonts.arabic,
        boldItalic: fonts.arabic,
      ),
      header: (ctx) => _header(
        fonts: fonts,
        lang: lang,
        title: _tr(lang, titleAr, titleEn),
        subtitle: _tr(lang, subtitleAr, subtitleEn),
        generatedBy: generatedBy,
        monthLabel: monthLabel,
        pageNumber: ctx.pageNumber,
        pagesCount: ctx.pagesCount,
      ),
      footer: (ctx) => _footer(
        fonts: fonts,
        lang: lang,
        pageNumber: ctx.pageNumber,
        pagesCount: ctx.pagesCount,
      ),
      build: (_) => build,
    );
  }

  pw.Widget _header({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required String title,
    required String subtitle,
    required String generatedBy,
    required int pageNumber,
    required int pagesCount,
    String? monthLabel,
  }) {
    final pageText = lang == ReportPdfLang.ar
        ? 'صفحة ${_digits(pageNumber.toString(), lang)} من ${_digits(pagesCount.toString(), lang)}'
        : 'Page ${_digits(pageNumber.toString(), lang)} of ${_digits(pagesCount.toString(), lang)}';

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey900,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        crossAxisAlignment:
        lang == ReportPdfLang.ar ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: lang == ReportPdfLang.ar
                ? [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    _line(
                      'WORKPULSE PLATFORM',
                      fonts: fonts,
                      size: 16,
                      color: PdfColors.white,
                      weight: pw.FontWeight.bold,
                      lang: lang,
                    ),
                    _line(
                      title,
                      fonts: fonts,
                      size: 10,
                      color: PdfColors.blue100,
                      lang: lang,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              _line(
                pageText,
                fonts: fonts,
                size: 10,
                color: PdfColors.white,
                lang: lang,
              ),
            ]
                : [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _line(
                      'WORKPULSE PLATFORM',
                      fonts: fonts,
                      size: 16,
                      color: PdfColors.white,
                      weight: pw.FontWeight.bold,
                      lang: lang,
                    ),
                    _line(
                      title,
                      fonts: fonts,
                      size: 10,
                      color: PdfColors.blue100,
                      lang: lang,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(width: 12),
              _line(
                pageText,
                fonts: fonts,
                size: 10,
                color: PdfColors.white,
                lang: lang,
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          _line(
            monthLabel == null ? subtitle : '$subtitle ${_safeMonthLabel(monthLabel, lang)}',
            fonts: fonts,
            size: 9,
            color: PdfColors.white,
            lang: lang,
          ),
          _line(
            lang == ReportPdfLang.ar
                ? 'تم التصدير بواسطة ${_safeGeneratorName(generatedBy, lang)}'
                : 'Exported by ${_safeGeneratorName(generatedBy, lang)}',
            fonts: fonts,
            size: 9,
            color: PdfColors.blue50,
            lang: lang,
          ),
        ],
      ),
    );
  }

  pw.Widget _footer({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required int pageNumber,
    required int pagesCount,
  }) {
    return pw.Column(
      crossAxisAlignment:
      lang == ReportPdfLang.ar ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
      children: [
        _line(
          _tr(lang, 'نبض العمل وثيقة تقرير رسمية', 'WorkPulse Official Report Document'),
          fonts: fonts,
          size: 8.5,
          color: PdfColors.grey700,
          lang: lang,
        ),
        _line(
          _footerText(pageNumber: pageNumber, pagesCount: pagesCount, lang: lang),
          fonts: fonts,
          size: 8.5,
          color: PdfColors.grey700,
          lang: lang,
        ),
      ],
    );
  }

  pw.Widget _kpi(
      String label,
      String value,
      _PdfFonts fonts,
      PdfColor color,
      ReportPdfLang lang,
      ) {
    final isAr = lang == ReportPdfLang.ar;
    final shownValue = isAr ? _digits(value, lang) : value;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.center,children: isAr
          ? [
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerRight, // النص يمين
            child: _line(
              label,
              fonts: fonts,
              size: 10,
              color: PdfColors.black,
              weight: pw.FontWeight.bold,
              lang: lang,
            ),
          ),
        ),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Align(
            alignment: pw.Alignment.centerLeft, // الرقم يسار
            child: _line(
              shownValue,
              fonts: fonts,
              size: 11,
              color: color,
              weight: pw.FontWeight.bold,
              lang: lang,
            ),
          ),
        ),
      ]
            : [
          pw.Expanded(
            child: pw.Align(
              alignment: pw.Alignment.centerLeft,
              child: _line(
                label,
                fonts: fonts,
                size: 10,
                color: PdfColors.black,
                weight: pw.FontWeight.bold,
                lang: lang,
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: _line(
                shownValue,
                fonts: fonts,
                size: 11,
                color: color,
                weight: pw.FontWeight.bold,
                lang: lang,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _record({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required String title,
    required List<String> lines,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.6),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment:
        lang == ReportPdfLang.ar ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
        children: [
          _line(title, fonts: fonts, size: 10.8, weight: pw.FontWeight.bold, lang: lang),
          pw.SizedBox(height: 4),
          ...lines.map(
                (line) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 2),
              child: _line(line, fonts: fonts, size: 9.5, color: PdfColors.grey800, lang: lang),
            ),
          ),
        ],
      ),
    );
  }
  pw.Widget _monthlyAttendanceDayCardFullWidth({
    required _PdfFonts fonts,
    required ReportPdfLang lang,
    required AdminMonthlyEmployeeAttendancePdfRow row,
  }) {
    final isAr = lang == ReportPdfLang.ar;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 10),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        border: pw.Border.all(color: PdfColors.blueGrey100, width: 0.8),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: isAr
            ? [
          pw.Expanded(
            child: pw.Directionality(
              textDirection: pw.TextDirection.rtl,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  _line(
                    row.attendanceDate,
                    fonts: fonts,
                    size: 11,
                    lang: lang,
                    color: PdfColors.blueGrey900,
                    weight: pw.FontWeight.bold,
                  ),
                  pw.SizedBox(height: 6),
                  _line(
                    _pair(lang, 'الحالة', 'Status', row.status),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                  ),
                  _line(
                    _pair(lang, 'العمل', 'Worked', _fmtMinutes(row.workedMinutes, lang)),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                  ),
                  _line(
                    _pair(
                      lang,
                      'تأخير غير معتمد',
                      'Unapproved Late',
                      '${row.unapprovedLateMinutes} ${_tr(lang, 'دقيقة', 'min')}',
                    ),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                    color: PdfColors.red700,
                  ),
                  _line(
                    _pair(
                      lang,
                      'خروج مبكر غير معتمد',
                      'Unapproved Early Leave',
                      '${row.unapprovedEarlyLeaveMinutes} ${_tr(lang, 'دقيقة', 'min')}',
                    ),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                    color: PdfColors.orange700,
                  ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Container(
            width: 7,
            height: 72,
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey900,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
        ]
            : [
          pw.Container(
            width: 7,
            height: 72,
            decoration: pw.BoxDecoration(
              color: PdfColors.blueGrey900,
              borderRadius: pw.BorderRadius.circular(4),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Directionality(
              textDirection: pw.TextDirection.ltr,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  _line(
                    row.attendanceDate,
                    fonts: fonts,
                    size: 11,
                    lang: lang,
                    color: PdfColors.blueGrey900,
                    weight: pw.FontWeight.bold,
                  ),
                  pw.SizedBox(height: 6),
                  _line(
                    _pair(lang, 'Status', 'Status', row.status),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                  ),
                  _line(
                    _pair(lang, 'Worked', 'Worked', _fmtMinutes(row.workedMinutes, lang)),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                  ),
                  _line(
                    _pair(
                      lang,
                      'Unapproved Late',
                      'Unapproved Late',
                      '${row.unapprovedLateMinutes} min',
                    ),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                    color: PdfColors.red700,
                  ),
                  _line(
                    _pair(
                      lang,
                      'Unapproved Early Leave',
                      'Unapproved Early Leave',
                      '${row.unapprovedEarlyLeaveMinutes} min',
                    ),
                    fonts: fonts,
                    size: 9.5,
                    lang: lang,
                    color: PdfColors.orange700,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  pw.Widget _line(
      String raw, {
        required _PdfFonts fonts,
        required double size,
        required ReportPdfLang lang,
        PdfColor color = PdfColors.black,
        pw.FontWeight weight = pw.FontWeight.normal,
      }) {
    final value = _safe(raw);

    final hasArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(value);
    final hasLatin = RegExp(r'[A-Za-z]').hasMatch(value);

    final direction = (hasArabic && !hasLatin)
        ? pw.TextDirection.rtl
        : (!hasArabic && hasLatin)
        ? pw.TextDirection.ltr
        : (lang == ReportPdfLang.ar ? pw.TextDirection.rtl : pw.TextDirection.ltr);

    final align = lang == ReportPdfLang.ar
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft;

    final textAlign = lang == ReportPdfLang.ar
        ? pw.TextAlign.right
        : pw.TextAlign.left;

    return pw.Align(
      alignment: align,
      child: pw.Text(
        value,
        textDirection: direction,
        textAlign: textAlign,
        style: pw.TextStyle(
          font: fonts.arabic,
          fontFallback: [fonts.fallback],
          fontSize: size,
          color: color,
          fontWeight: weight,
        ),
      ),
    );
  }

  String _tr(ReportPdfLang lang, String ar, String en) =>
      lang == ReportPdfLang.ar ? ar : en;

  String _pair(ReportPdfLang lang, String ar, String en, String value) =>
      lang == ReportPdfLang.ar ? '$ar $value' : '$en: $value';

  String _safe(String input) {
    return input
        .replaceAll(RegExp(r'[\u200E\u200F\u202A-\u202E\u2066-\u2069\uFEFF]'), '')
        .replaceAll('•', ' ')
        .replaceAll('‏', '')
        .replaceAll('‎', '')
        .trim();
  }

  String _safeGeneratorName(String? raw, ReportPdfLang lang) {
    final x = _safe(raw ?? '');
    if (x.isEmpty) return lang == ReportPdfLang.ar ? 'الإدارة' : 'Administration';
    return x;
  }

  String _safeMonthLabel(String raw, ReportPdfLang lang) {
    return _digits(_safe(raw).replaceAll('-', ' '), lang);
  }

  String _digits(String input, ReportPdfLang lang) {
    if (lang == ReportPdfLang.en) return input;
    const western = '0123456789';
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    var out = input;
    for (var i = 0; i < western.length; i++) {
      out = out.replaceAll(western[i], arabic[i]);
    }
    return out;
  }

  String _fmtMinutes(int minutes, ReportPdfLang lang) {
    if (minutes <= 0) return lang == ReportPdfLang.ar ? '٠ دقيقة' : '0 min';

    final h = minutes ~/ 60;
    final m = minutes % 60;

    if (lang == ReportPdfLang.en) {
      if (h == 0) return '$m min';
      if (m == 0) return '$h hr';
      return '$h hr $m min';
    }

    if (h == 0) return '${_digits(m.toString(), lang)} دقيقة';
    if (m == 0) return '${_digits(h.toString(), lang)} ساعة';
    return '${_digits(h.toString(), lang)} ساعة و ${_digits(m.toString(), lang)} دقيقة';
  }

  String _footerText({
    required int pageNumber,
    required int pagesCount,
    required ReportPdfLang lang,
  }) {
    final now = DateTime.now();

    final y = _digits(now.year.toString().padLeft(4, '0'), lang);
    final m = _digits(now.month.toString().padLeft(2, '0'), lang);
    final d = _digits(now.day.toString().padLeft(2, '0'), lang);
    final h = _digits(now.hour.toString().padLeft(2, '0'), lang);
    final min = _digits(now.minute.toString().padLeft(2, '0'), lang);
    final p = _digits(pageNumber.toString(), lang);
    final t = _digits(pagesCount.toString(), lang);

    if (lang == ReportPdfLang.en) {
      return 'Exported on $y-$m-$d at $h:$min • Page $p of $t';
    }

    return 'تاريخ التصدير السنة $y الشهر $m اليوم $d الساعة $h والدقيقة $min الصفحة $p من $t';
  }

  String _dateTimeWords(ReportPdfLang lang) {
    final now = DateTime.now();
    final y = _digits(now.year.toString().padLeft(4, '0'), lang);
    final m = _digits(now.month.toString().padLeft(2, '0'), lang);
    final d = _digits(now.day.toString().padLeft(2, '0'), lang);
    final h = _digits(now.hour.toString().padLeft(2, '0'), lang);
    final min = _digits(now.minute.toString().padLeft(2, '0'), lang);

    if (lang == ReportPdfLang.en) {
      return '$y-$m-$d $h:$min';
    }

    return 'السنة $y الشهر $m اليوم $d الساعة $h والدقيقة $min';
  }

  Future<_PdfFonts> _fonts() async {
    final a = await _loadArabicFont();
    final f = await _loadFallbackFont();
    return _PdfFonts(arabic: a, fallback: f);
  }

  Future<pw.Font> _loadArabicFont() async {
    if (_fontArabic != null) return _fontArabic!;
    final data = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    _fontArabicBytes = data.buffer.asUint8List();
    _fontArabic = pw.Font.ttf(data);
    return _fontArabic!;
  }

  Future<pw.Font> _loadFallbackFont() async {
    if (_fontFallback != null) return _fontFallback!;
    _fontFallback = pw.Font.helvetica();
    return _fontFallback!;
  }

  Future<Uint8List> _loadArabicFontBytes() async {
    if (_fontArabicBytes != null) return _fontArabicBytes!;
    final data = await rootBundle.load('assets/fonts/NotoNaskhArabic-Regular.ttf');
    _fontArabicBytes = data.buffer.asUint8List();
    return _fontArabicBytes!;
  }
}

class _PdfFonts {
  final pw.Font arabic;
  final pw.Font fallback;

  const _PdfFonts({
    required this.arabic,
    required this.fallback,
  });
}