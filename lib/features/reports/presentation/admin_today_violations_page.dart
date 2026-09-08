import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:workpulse/features/reports/presentation/providers/reports_provider.dart';
import 'package:workpulse/features/reports/pdf/reports_pdf_service.dart';
import 'package:workpulse/shared/widgets/pdf_preview_page.dart';

import '../data/models/admin_today_violation_model.dart';

class AdminTodayViolationsPage extends ConsumerStatefulWidget {
  const AdminTodayViolationsPage({super.key});

  @override
  ConsumerState<AdminTodayViolationsPage> createState() =>
      _AdminTodayViolationsPageState();
}

class _AdminTodayViolationsPageState
    extends ConsumerState<AdminTodayViolationsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'all';
  String _severityFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportsProvider.notifier).loadAdminTodayViolations();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(reportsProvider.notifier).loadAdminTodayViolations();
  }

  String _t(bool isEn, String ar, String en) => isEn ? en : ar;

  String _statusText(String status, bool isEn) {
    switch (status) {
      case 'late':
        return _t(isEn, 'تأخير غير معتمد', 'Unapproved Late');
      case 'early_leave':
        return _t(isEn, 'خروج مبكر غير معتمد', 'Unapproved Early Leave');
      case 'early_leave_partial':
        return _t(isEn, 'خروج مبكر جزئي', 'Partially Approved Early Leave');
      case 'late_checked_out':
        return _t(isEn, 'مكتمل مع تأخير', 'Checked Out with Late');
      case 'hours_incomplete':
        return _t(isEn, 'ساعات ناقصة', 'Incomplete Hours');
      default:
        return status;
    }
  }

  int _score(AdminTodayViolationModel v) {
    return v.unapprovedLateMinutes + v.unapprovedEarlyLeaveMinutes;
  }

  String _severityLabel(int score, bool isEn) {
    if (score >= 120) return _t(isEn, 'شديدة', 'Critical');
    if (score >= 60) return _t(isEn, 'مرتفعة', 'High');
    if (score >= 20) return _t(isEn, 'متوسطة', 'Medium');
    return _t(isEn, 'خفيفة', 'Low');
  }

  Color _severityColor(int score) {
    if (score >= 120) return const Color(0xFF991B1B);
    if (score >= 60) return const Color(0xFFDC2626);
    if (score >= 20) return const Color(0xFFF59E0B);
    return const Color(0xFF0284C7);
  }

  String _workedText(int minutes, bool isEn) {
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

  bool _matchStatus(AdminTodayViolationModel v) {
    if (_statusFilter == 'all') return true;
    return v.status == _statusFilter;
  }

  bool _matchSeverity(AdminTodayViolationModel v, bool isEn) {
    if (_severityFilter == 'all') return true;
    return _severityLabel(_score(v), isEn) == _severityFilter;
  }

  bool _matchSearch(AdminTodayViolationModel v) {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) return true;
    return v.employeeName.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isEn = localeCode == 'en';
    final reportLang = isEn ? 'en' : 'ar';

    final allViolations = [...state.todayViolations]
      ..sort((a, b) => _score(b).compareTo(_score(a)));

    final visible = allViolations
        .where(_matchStatus)
        .where((v) => _matchSeverity(v, isEn))
        .where(_matchSearch)
        .toList();

    final totalScore = allViolations.fold<int>(0, (s, v) => s + _score(v));

    return Directionality(
      textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF0F766E),
          foregroundColor: Colors.white,
          title: Text(
            _t(isEn, 'جميع مخالفات اليوم', 'Today Violations'),
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          actions: [
            IconButton(
              tooltip: 'PDF',
              onPressed: allViolations.isEmpty
                  ? null
                  : () async {
                final rows = allViolations
                    .map(
                      (v) => AdminViolationPdfRow(
                    employeeName: v.employeeName,
                    attendanceDate: v.attendanceDate,
                    status: _statusText(v.status, isEn),
                    unapprovedLateMinutes: v.unapprovedLateMinutes,
                    unapprovedEarlyLeaveMinutes: v.unapprovedEarlyLeaveMinutes,
                    workedMinutes: v.workedMinutes,
                  ),
                )
                    .toList();

                final bytes = await ReportsPdfService.instance.buildAdminViolationsReportPdf(
                  rows: rows,
                  generatedBy: isEn ? 'Administration' : 'الإدارة',
                  lang: reportLang,
                );

                if (!context.mounted) return;
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PdfPreviewPage(
                      bytes: bytes,
                      title: _t(isEn, 'معاينة تقرير مخالفات اليوم', 'Today Violations Preview'),
                      fileName: 'nabd_alamal_today_violations.pdf',
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
            ),
            IconButton(
              tooltip: _t(isEn, 'تحديث', 'Refresh'),
              onPressed: state.isLoading ? null : _refresh,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (state.isLoading && allViolations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null && allViolations.isEmpty) {
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

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HeaderKpi(
                    totalViolations: allViolations.length,
                    totalMinutes: totalScore,
                    isEn: isEn,
                  ),
                  const SizedBox(height: 10),
                  _FiltersBar(
                    isEn: isEn,
                    searchController: _searchController,
                    statusValue: _statusFilter,
                    severityValue: _severityFilter,
                    onStatusChanged: (v) => setState(() => _statusFilter = v),
                    onSeverityChanged: (v) => setState(() => _severityFilter = v),
                    onSearchChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  if (visible.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        _t(isEn, 'لا توجد نتائج مطابقة للفلاتر الحالية', 'No matching results for current filters'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  else
                    ...visible.asMap().entries.map((entry) {
                      final index = entry.key;
                      final v = entry.value;
                      final score = _score(v);
                      final accent = _severityColor(score);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ViolationCard(
                          rank: index + 1,
                          employeeName: v.employeeName,
                          statusText: _statusText(v.status, isEn),
                          totalMinutes: score,
                          severityLabel: _severityLabel(score, isEn),
                          severityColor: accent,
                          lateMinutes: v.unapprovedLateMinutes,
                          earlyMinutes: v.unapprovedEarlyLeaveMinutes,
                          workedText: _workedText(v.workedMinutes, isEn),
                          isEn: isEn,
                        ),
                      );
                    }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _HeaderKpi extends StatelessWidget {
  const _HeaderKpi({
    required this.totalViolations,
    required this.totalMinutes,
    required this.isEn,
  });

  final int totalViolations;
  final int totalMinutes;
  final bool isEn;

  String _t(String ar, String en) => isEn ? en : ar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _KpiItem(
              title: _t('عدد المخالفات', 'Total Violations'),
              value: '$totalViolations',
            ),
          ),
          Container(width: 1, height: 36, color: Colors.white24),
          Expanded(
            child: _KpiItem(
              title: _t('إجمالي دقائق المخالفات', 'Total Violation Minutes'),
              value: isEn ? '$totalMinutes min' : '$totalMinutes د',
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiItem extends StatelessWidget {
  const _KpiItem({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFFCCFBF1),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.isEn,
    required this.searchController,
    required this.statusValue,
    required this.severityValue,
    required this.onStatusChanged,
    required this.onSeverityChanged,
    required this.onSearchChanged,
  });

  final bool isEn;
  final TextEditingController searchController;
  final String statusValue;
  final String severityValue;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSeverityChanged;
  final ValueChanged<String> onSearchChanged;

  String _t(String ar, String en) => isEn ? en : ar;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: _t('بحث باسم الموظف', 'Search by employee name'),
            prefixIcon: const Icon(Icons.search_rounded),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: statusValue,
                decoration: InputDecoration(
                  labelText: _t('الحالة', 'Status'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  DropdownMenuItem(value: 'all', child: Text(_t('الكل', 'All'))),
                  DropdownMenuItem(value: 'late', child: Text(_t('تأخير', 'Late'))),
                  DropdownMenuItem(value: 'early_leave', child: Text(_t('خروج مبكر', 'Early Leave'))),
                  DropdownMenuItem(value: 'early_leave_partial', child: Text(_t('خروج جزئي', 'Partial Early Leave'))),
                  DropdownMenuItem(value: 'late_checked_out', child: Text(_t('مكتمل مع تأخير', 'Checked Out with Late'))),
                  DropdownMenuItem(value: 'hours_incomplete', child: Text(_t('ساعات ناقصة', 'Incomplete Hours'))),
                ],
                onChanged: (v) {
                  if (v != null) onStatusChanged(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: severityValue,
                decoration: InputDecoration(
                  labelText: _t('الخطورة', 'Severity'),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  DropdownMenuItem(value: 'all', child: Text(_t('الكل', 'All'))),
                  DropdownMenuItem(value: _t('خفيفة', 'Low'), child: Text(_t('خفيفة', 'Low'))),
                  DropdownMenuItem(value: _t('متوسطة', 'Medium'), child: Text(_t('متوسطة', 'Medium'))),
                  DropdownMenuItem(value: _t('مرتفعة', 'High'), child: Text(_t('مرتفعة', 'High'))),
                  DropdownMenuItem(value: _t('شديدة', 'Critical'), child: Text(_t('شديدة', 'Critical'))),
                ],
                onChanged: (v) {
                  if (v != null) onSeverityChanged(v);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ViolationCard extends StatelessWidget {
  const _ViolationCard({
    required this.rank,
    required this.employeeName,
    required this.statusText,
    required this.totalMinutes,
    required this.severityLabel,
    required this.severityColor,
    required this.lateMinutes,
    required this.earlyMinutes,
    required this.workedText,
    required this.isEn,
  });

  final int rank;
  final String employeeName;
  final String statusText;
  final int totalMinutes;
  final String severityLabel;
  final Color severityColor;
  final int lateMinutes;
  final int earlyMinutes;
  final String workedText;
  final bool isEn;

  String _t(String ar, String en) => isEn ? en : ar;

  @override
  Widget build(BuildContext context) {
    final score = (totalMinutes / 180).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: isEn ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            children: isEn
                ? [
              CircleAvatar(
                radius: 17,
                backgroundColor: severityColor.withValues(alpha: 0.12),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  employeeName.isEmpty ? _t('غير معروف', 'Unknown') : employeeName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$severityLabel - ${isEn ? '$totalMinutes min' : '$totalMinutes د'}',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ]
                : [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: severityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$severityLabel - $totalMinutes د',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  employeeName.isEmpty ? _t('غير معروف', 'Unknown') : employeeName,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 17,
                backgroundColor: severityColor.withValues(alpha: 0.12),
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: severityColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_t('الحالة', 'Status')}: $statusText',
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(severityColor),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (lateMinutes > 0)
                _MetricChip(
                  label: _t('تأخير غير معتمد', 'Unapproved Late'),
                  value: isEn ? '$lateMinutes min' : '$lateMinutes د',
                  color: const Color(0xFFDC2626),
                ),
              if (earlyMinutes > 0)
                _MetricChip(
                  label: _t('خروج مبكر غير معتمد', 'Unapproved Early Leave'),
                  value: isEn ? '$earlyMinutes min' : '$earlyMinutes د',
                  color: const Color(0xFFF59E0B),
                ),
              _MetricChip(
                label: _t('ساعات العمل', 'Worked Hours'),
                value: workedText,
                color: const Color(0xFF0284C7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}