import 'dart:async';
import 'dart:math' as math;

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/admin_correction_report_row_model.dart';
import '../models/admin_geofence_report_row_model.dart';
import '../models/admin_leave_monthly_report_row_model.dart';
import '../models/admin_permissions_report_row_model.dart';
import '../models/admin_today_summary_model.dart';
import '../models/admin_today_violation_model.dart';
import '../models/admin_today_work_hours_model.dart';

class ReportsRepository {
  final SupabaseClient _client;

  ReportsRepository(this._client);

  String _dateOnly(DateTime d) {
    final x = d.toLocal();
    return '${x.year.toString().padLeft(4, '0')}-'
        '${x.month.toString().padLeft(2, '0')}-'
        '${x.day.toString().padLeft(2, '0')}';
  }

  double _toRadians(double deg) => deg * (math.pi / 180);

  double _haversineMeters({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusM = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusM * c;
  }

  Future<AdminTodaySummaryModel> getAdminTodaySummary() async {
    final data = await _client
        .rpc('admin_report_today_summary')
        .timeout(const Duration(seconds: 20));

    if (data is List && data.isNotEmpty) {
      return AdminTodaySummaryModel.fromJson(
        Map<String, dynamic>.from(data.first),
      );
    }

    if (data is Map) {
      return AdminTodaySummaryModel.fromJson(
        Map<String, dynamic>.from(data),
      );
    }

    throw Exception('تعذر تحميل ملخص تقرير اليوم');
  }

  Future<List<AdminTodayViolationModel>> getAdminTodayViolations({
    int limit = 50,
  }) async {
    final data = await _client
        .rpc(
      'admin_report_today_violations',
      params: {'p_limit': limit},
    )
        .timeout(const Duration(seconds: 20));

    if (data is List) {
      return data
          .map<AdminTodayViolationModel>(
            (e) => AdminTodayViolationModel.fromJson(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList();
    }

    return const [];
  }

  Future<List<AdminTodayWorkHoursModel>> getAdminWorkHoursReportByMonth({
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final data = await _client
        .from('attendance_records')
        .select('''
          employee_id,
          attendance_date,
          status,
          worked_minutes,
          profiles!attendance_records_employee_id_fkey(
            full_name,
            work_schedules(
              required_minutes,
              schedule_type
            )
          )
        ''')
        .gte('attendance_date', _dateOnly(start))
        .lt('attendance_date', _dateOnly(end))
        .order('attendance_date', ascending: false)
        .order('created_at', ascending: false);

    if (data is List) {
      return data
          .map<AdminTodayWorkHoursModel>(
            (e) => AdminTodayWorkHoursModel.fromJoinedRow(
          Map<String, dynamic>.from(e as Map),
        ),
      )
          .toList();
    }

    return const [];
  }

  Future<List<AdminLeaveMonthlyReportRowModel>> getAdminLeavesReportByMonth({
    required DateTime month,
    String status = 'all',
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final endInclusive = end.subtract(const Duration(days: 1));

    dynamic query = _client
        .from('leaves')
        .select('''
          id,
          employee_id,
          leave_type_id,
          start_date,
          end_date,
          total_days,
          status,
          reason,
          profiles!leaves_employee_id_fkey(full_name),
          leave_types!leaves_leave_type_id_fkey(name)
        ''')
        .lte('start_date', _dateOnly(endInclusive))
        .gte('end_date', _dateOnly(start));

    if (status != 'all') {
      query = query.eq('status', status);
    }

    final data = await query
        .order('start_date', ascending: false)
        .order('created_at', ascending: false);

    return (data as List).map<AdminLeaveMonthlyReportRowModel>((row) {
      final item = Map<String, dynamic>.from(row as Map);
      final profile = item['profiles'] as Map<String, dynamic>?;
      final leaveType = item['leave_types'] as Map<String, dynamic>?;

      return AdminLeaveMonthlyReportRowModel.fromJson({
        ...item,
        'employee_name': profile?['full_name'],
        'leave_type_name': leaveType?['name'],
      });
    }).toList();
  }

  Future<List<AdminPermissionsReportRowModel>> getAdminPermissionsReportByMonth({
    required DateTime month,
    String status = 'all',
    String type = 'all',
    int limit = 500,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    dynamic query = _client
        .from('permissions')
        .select('''
          id,
          employee_id,
          permission_date,
          type,
          status,
          total_minutes,
          reason,
          profiles!permissions_employee_id_fkey(
            full_name
          )
        ''')
        .gte('permission_date', _dateOnly(start))
        .lt('permission_date', _dateOnly(end));

    if (status != 'all') {
      query = query.eq('status', status);
    }

    if (type != 'all') {
      query = query.eq('type', type);
    }

    final data = await query
        .order('permission_date', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List).map<AdminPermissionsReportRowModel>((row) {
      final item = Map<String, dynamic>.from(row as Map);
      final profile = item['profiles'] as Map<String, dynamic>?;

      return AdminPermissionsReportRowModel.fromJson({
        ...item,
        'employee_name': profile?['full_name'],
      });
    }).toList();
  }

  Future<List<AdminCorrectionReportRowModel>> getAdminCorrectionsReportByMonth({
    required DateTime month,
    String status = 'all',
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    dynamic query = _client
        .from('corrections')
        .select('''
          id,
          employee_id,
          correction_date,
          type,
          requested_time,
          status,
          reason,
          rejection_reason,
          profiles!corrections_employee_id_fkey(
            full_name
          )
        ''')
        .gte('correction_date', _dateOnly(start))
        .lt('correction_date', _dateOnly(end));

    if (status != 'all') {
      query = query.eq('status', status);
    }

    final data = await query
        .order('correction_date', ascending: false)
        .order('created_at', ascending: false);

    return (data as List).map<AdminCorrectionReportRowModel>((row) {
      final item = Map<String, dynamic>.from(row as Map);
      final profile = item['profiles'] as Map<String, dynamic>?;

      return AdminCorrectionReportRowModel.fromJson({
        ...item,
        'employee_name': profile?['full_name'],
      });
    }).toList();
  }

  Future<List<AdminGeofenceReportRowModel>> getAdminGeofenceReportByMonth({
    required DateTime month,
    bool outsideOnly = false,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final data = await _client
        .from('attendance_records')
        .select('''
          employee_id,
          attendance_date,
          status,
          profiles!attendance_records_employee_id_fkey(
            full_name,
            current_lat,
            current_lng,
            current_location_updated_at,
            work_schedules(
              geofence_enabled,
              geofence_lat,
              geofence_lng,
              geofence_radius_m
            )
          )
        ''')
        .gte('attendance_date', _dateOnly(start))
        .lt('attendance_date', _dateOnly(end))
        .order('attendance_date', ascending: false);

    final result = <AdminGeofenceReportRowModel>[];

    for (final row in data as List) {
      final item = Map<String, dynamic>.from(row as Map);
      final profile = item['profiles'] as Map<String, dynamic>? ?? {};
      final schedule = profile['work_schedules'] as Map<String, dynamic>? ?? {};

      final geofenceEnabled = schedule['geofence_enabled'] == true;
      final centerLat = (schedule['geofence_lat'] as num?)?.toDouble();
      final centerLng = (schedule['geofence_lng'] as num?)?.toDouble();
      final radius = (schedule['geofence_radius_m'] as num?)?.toInt() ?? 100;

      final currentLat = (profile['current_lat'] as num?)?.toDouble();
      final currentLng = (profile['current_lng'] as num?)?.toDouble();

      double? distance;
      bool outside = false;

      if (geofenceEnabled &&
          centerLat != null &&
          centerLng != null &&
          currentLat != null &&
          currentLng != null) {
        distance = _haversineMeters(
          lat1: centerLat,
          lon1: centerLng,
          lat2: currentLat,
          lon2: currentLng,
        );
        outside = distance > radius;
      }

      final model = AdminGeofenceReportRowModel.fromJson({
        'employee_id': item['employee_id'],
        'employee_name': profile['full_name'],
        'attendance_date': item['attendance_date'],
        'status': item['status'],
        'geofence_enabled': geofenceEnabled,
        'distance_meters': distance,
        'geofence_radius_m': radius,
        'is_outside': outside,
        'location_updated_at': profile['current_location_updated_at'],
      });

      if (!outsideOnly || model.isOutside) {
        result.add(model);
      }
    }

    return result;
  }
}