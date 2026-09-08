import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reports = <_AdminReportItem>[
      const _AdminReportItem(
        title: 'ملخص الحضور اليومي',
        subtitle: 'نظرة عامة على وضع اليوم',
        route: '/admin/reports/daily-summary',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير المخالفات اليومية',
        subtitle: 'تأخير وخروج مبكر غير معتمد',
        route: '/admin/reports/violations',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'الحضور الشهري حسب الموظف',
        subtitle: 'اختيار موظف وعرض سجله الشهري',
        route: '/admin/reports/monthly-attendance-by-employee',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير التأخير (معتمد/غير معتمد)',
        subtitle: 'تحليل أنواع التأخير',
        route: '/admin/reports/late',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير الخروج المبكر (معتمد/غير معتمد)',
        subtitle: 'تحليل حالات الانصراف المبكر',
        route: '/admin/reports/early-leave',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير ساعات العمل',
        subtitle: 'المطلوب والمنجز والإضافي',
        route: '/admin/reports/work-hours',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير الإجازات',
        subtitle: 'استهلاك/متبقي/معلق',
        route: '/admin/reports/leaves',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير الأذونات',
        subtitle: 'Pending / Approved / Rejected',
        route: '/admin/reports/permissions',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير تعديلات البصمة',
        subtitle: 'طلب / اعتماد / رفض',
        route: '/admin/reports/corrections',
        isReady: true,
      ),
      const _AdminReportItem(
        title: 'تقرير الالتزام الجغرافي',
        subtitle: 'داخل/خارج النطاق أثناء الدوام',
        route: '/admin/reports/geofence',
        isReady: true,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        title: const Text(
          'تقارير الإدارة',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = reports[index];
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFECFDF5),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF0F766E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(item.subtitle),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF0F766E),
              ),
              onTap: () => _openReport(context, item),
            ),
          );
        },
      ),
    );
  }

  void _openReport(BuildContext context, _AdminReportItem item) {
    if (!item.isReady || item.route == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هذا التقرير قيد التجهيز')),
      );
      return;
    }
    context.push(item.route!);
  }
}

class _AdminReportItem {
  final String title;
  final String subtitle;
  final String? route;
  final bool isReady;

  const _AdminReportItem({
    required this.title,
    required this.subtitle,
    required this.route,
    required this.isReady,
  });
}