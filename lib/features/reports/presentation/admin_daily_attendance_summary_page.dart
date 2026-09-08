import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:workpulse/features/reports/presentation/providers/reports_provider.dart';
import 'package:workpulse/features/reports/pdf/reports_pdf_service.dart';
import 'package:workpulse/shared/widgets/pdf_preview_page.dart';

class AdminDailyAttendanceSummaryPage extends ConsumerStatefulWidget {
  const AdminDailyAttendanceSummaryPage({super.key});

  @override
  ConsumerState<AdminDailyAttendanceSummaryPage> createState() =>
      _AdminDailyAttendanceSummaryPageState();
}

class _AdminDailyAttendanceSummaryPageState
    extends ConsumerState<AdminDailyAttendanceSummaryPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(reportsProvider.notifier).loadAdminTodaySummary();
    });
  }

  Future<void> _refresh() async {
    await ref.read(reportsProvider.notifier).loadAdminTodaySummary();
  }

  String _t(bool isEn, String ar, String en) => isEn ? en : ar;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportsProvider);
    final summary = state.adminTodaySummary;

    final localeCode = Localizations.localeOf(context).languageCode.toLowerCase();
    final isEn = localeCode == 'en';
    final reportLang = isEn ? 'en' : 'ar';

    final themed = Theme.of(context).copyWith(
      textTheme: Theme.of(context).textTheme.apply(fontFamily: 'ArabicPdf'),
    );

    return Theme(
      data: themed,
      child: Directionality(
        textDirection: isEn ? TextDirection.ltr : TextDirection.rtl,
        child: Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF0F766E),
            foregroundColor: Colors.white,
            title: Text(
              _t(isEn, 'تقرير ملخص الحضور اليومي', 'Daily Attendance Summary Report'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            actions: [
              IconButton(
                tooltip: _t(isEn, 'تصدير PDF', 'Export PDF'),
                onPressed: summary == null
                    ? null
                    : () async {
                  try {
                    final bytes = await ReportsPdfService.instance
                        .buildAdminDailyAttendanceSummaryPdf(
                      summary: summary,
                      generatedBy: isEn ? 'Administration' : 'الإدارة',
                      lang: reportLang,
                    );

                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PdfPreviewPage(
                          bytes: bytes,
                          title: _t(isEn, 'معاينة ملخص الحضور اليومي', 'Daily Summary Preview'),
                          fileName: 'workpulse_daily_summary.pdf',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          _t(isEn, 'فشل تصدير PDF: $e', 'PDF export failed: $e'),
                        ),
                      ),
                    );
                  }
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
              if (state.isLoading && summary == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null && summary == null) {
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

              if (summary == null) {
                return Center(
                  child: Text(
                    _t(isEn, 'لا توجد بيانات متاحة حاليا', 'No data available right now'),
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F766E), Color(0xFF155E75)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _t(
                          isEn,
                          'نظرة شاملة على وضع الحضور لهذا اليوم',
                          'Comprehensive overview of today attendance',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _SummaryCard(
                          title: _t(isEn, 'إجمالي الموظفين', 'Total Employees'),
                          value: '${summary.totalEmployees}',
                          icon: Icons.people_alt_rounded,
                          color: const Color(0xFF0F766E),
                        ),
                        _SummaryCard(
                          title: _t(isEn, 'داخل الدوام الآن', 'Currently Checked In'),
                          value: '${summary.checkedInNow}',
                          icon: Icons.login_rounded,
                          color: const Color(0xFF0284C7),
                        ),
                        _SummaryCard(
                          title: _t(isEn, 'أكملوا الدوام', 'Completed Today'),
                          value: '${summary.completedToday}',
                          icon: Icons.task_alt_rounded,
                          color: const Color(0xFF7C3AED),
                        ),
                        _SummaryCard(
                          title: _t(isEn, 'تأخير اليوم', 'Late Today'),
                          value: '${summary.lateToday}',
                          icon: Icons.warning_amber_rounded,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _SummaryCardWide(
                      title: _t(isEn, 'على إجازة معتمدة اليوم', 'On Approved Leave Today'),
                      value: '${summary.onApprovedLeaveToday}',
                      icon: Icons.beach_access_rounded,
                      color: const Color(0xFFF59E0B),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isEn = Directionality.of(context) == TextDirection.ltr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: isEn ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCardWide extends StatelessWidget {
  const _SummaryCardWide({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isEn = Directionality.of(context) == TextDirection.ltr;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: isEn
            ? [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ]
            : [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}