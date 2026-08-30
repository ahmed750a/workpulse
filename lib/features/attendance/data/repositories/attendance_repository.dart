import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_break_model.dart';
import '../../../../../core/services/work_timer_service.dart';
import '../models/attendance_record_model.dart';
import '../models/work_schedule_model.dart';
import 'work_schedule_repository.dart';

class AttendanceRepository {
  final SupabaseClient _client;
  final WorkScheduleRepository _scheduleRepository;

  // السماح بالحضور قبل بداية الدوام بحد أقصى 10 دقائق
  static const int _earlyCheckInAllowanceMinutes = 10;

  AttendanceRepository(this._client, this._scheduleRepository);
  String _authUserId() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('المستخدم غير مسجل الدخول');
    }
    return user.id;
  }

  String _dateOnly(DateTime date) {
    final d = date.toLocal();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  DateTime _timeToDateTimeForDate(DateTime date, String time) {
    final localDate = date.toLocal();
    final parts = time.split(':');

    return DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<AttendanceBreakModel?> getActiveBreak() async {
    final employeeId = _authUserId();
    final rows = await _client
        .from('attendance_breaks')
        .select()
        .eq('employee_id', employeeId)
        .eq('status', 'active')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return AttendanceBreakModel.fromJson(rows.first);
  }

  Future<List<AttendanceBreakModel>> getTodayBreaks() async {
    final employeeId = _authUserId();
    final record = await getTodayRecord();

    if (record == null) return [];

    final rows = await _client
        .from('attendance_breaks')
        .select()
        .eq('employee_id', employeeId)
        .eq('attendance_record_id', record.id)
        .order('created_at', ascending: false);

    return rows
        .map<AttendanceBreakModel>(
          (item) => AttendanceBreakModel.fromJson(item),
    )
        .toList();
  }

  Future<int> getTodayBreakMinutes() async {
    final breaks = await getTodayBreaks();

    int total = 0;

    for (final item in breaks) {
      total += item.breakMinutes;
    }

    return total;
  }

  Future<Map<String, int>> _getTodayExitReturnUsageBreakdown({
    required String employeeId,
    required List<AttendanceBreakModel> todayBreaks,
  }) async {
    final permission = await _getTodayApprovedExitReturnPermission(
      employeeId: employeeId,
    );

    // إذا لا يوجد إذن خروج/عودة معتمد اليوم، كل الدقائق تعتبر غير مغطاة بالإذن
    if (permission == null) {
      final total = todayBreaks.fold<int>(0, (sum, b) => sum + b.breakMinutes);
      return {
        'approvedMinutes': 0,
        'unapprovedMinutes': total,
      };
    }

    final today = DateTime.now();
    final permissionStart = _permissionTimeOnDate(
      time: permission['start_time'].toString(),
      date: today,
    );
    final permissionEnd = _permissionTimeOnDate(
      time: permission['end_time'].toString(),
      date: today,
    );

    int approved = 0;
    int unapproved = 0;

    for (final b in todayBreaks) {
      final breakStart = DateTime.parse(b.breakStartAt).toLocal();
      final breakEnd = b.breakEndAt != null
          ? DateTime.parse(b.breakEndAt!).toLocal()
          : DateTime.now();

      if (!breakEnd.isAfter(breakStart)) continue;

      final totalMinutes = breakEnd.difference(breakStart).inMinutes;

      final overlapStart =
      breakStart.isAfter(permissionStart) ? breakStart : permissionStart;
      final overlapEnd = breakEnd.isBefore(permissionEnd) ? breakEnd : permissionEnd;

      int approvedMinutes = 0;
      if (overlapEnd.isAfter(overlapStart)) {
        approvedMinutes = overlapEnd.difference(overlapStart).inMinutes;
      }

      if (approvedMinutes < 0) approvedMinutes = 0;
      if (approvedMinutes > totalMinutes) approvedMinutes = totalMinutes;

      final unapprovedMinutes = totalMinutes - approvedMinutes;

      approved += approvedMinutes;
      unapproved += unapprovedMinutes;
    }

    return {
      'approvedMinutes': approved,
      'unapprovedMinutes': unapproved,
    };
  }

  Future<AttendanceBreakModel> startBreak() async {
    final employeeId = _authUserId();
    final schedule =
    await _scheduleRepository.getScheduleForEmployee(employeeId);

    if (schedule.scheduleType != 'hourly') {
      throw Exception('الراحة متاحة فقط لنظام دوام الساعات');
    }

    final record = await getTodayRecord();

    if (record == null || record.checkInAt == null) {
      throw Exception('يجب بدء الدوام الساعي أولاً');
    }

    if (record.checkOutAt != null) {
      throw Exception('لا يمكن بدء راحة بعد إنهاء الدوام');
    }

    final activeBreak = await getActiveBreak();
    if (activeBreak != null) {
      throw Exception('يوجد راحة نشطة بالفعل');
    }

    final now = DateTime.now();

    final rows = await _client.from('attendance_breaks').insert({
      'attendance_record_id': record.id,
      'employee_id': employeeId,
      'break_start_at': now.toUtc().toIso8601String(),
      'status': 'active',
      'break_minutes': 0,
      'updated_at': now.toUtc().toIso8601String(),
    }).select();

    if (rows.isEmpty) {
      throw Exception('فشل بدء الراحة');
    }

    return AttendanceBreakModel.fromJson(rows.first);
  }

  Future<AttendanceBreakModel> endBreak() async {
    final employeeId = _authUserId();
    final activeBreak = await getActiveBreak();

    if (activeBreak == null) {
      throw Exception('لا توجد راحة نشطة');
    }

    final now = DateTime.now();
    final start = DateTime.parse(activeBreak.breakStartAt).toLocal();

    int minutes = now.difference(start).inMinutes;
    if (minutes < 0) minutes = 0;

    final rows = await _client
        .from('attendance_breaks')
        .update({
      'break_end_at': now.toUtc().toIso8601String(),
      'break_minutes': minutes,
      'status': 'ended',
      'updated_at': now.toUtc().toIso8601String(),
    })
        .eq('id', activeBreak.id)
        .select();

    if (rows.isEmpty) {
      throw Exception('فشل إنهاء الراحة');
    }

    return AttendanceBreakModel.fromJson(rows.first);
  }

  Future<Map<String, dynamic>?> _getApprovedPermission({
    required String employeeId,
    required String date,
    required String type,
  }) async {
    final rows = await _client
        .from('permissions')
        .select()
        .eq('employee_id', employeeId)
        .eq('permission_date', date)
        .eq('type', type)
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<bool> _hasApprovedLeaveForDate({
    required String employeeId,
    required String date,
  }) async {
    final row = await _client
        .from('leaves')
        .select('id')
        .eq('employee_id', employeeId)
        .eq('status', 'approved')
        .lte('start_date', date)
        .gte('end_date', date)
        .limit(1)
        .maybeSingle();

    return row != null;
  }

  Future<AttendanceRecordModel?> getTodayRecord() async {
    final employeeId = _authUserId();

    final rows = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return AttendanceRecordModel.fromJson(rows.first);
  }
  DateTime _safeCheckoutLocalTime({
    required AttendanceRecordModel existing,
    required DateTime rawCheckoutLocal,
  }) {
    // وقت الحضور الفعلي (محول لـ local)
    final checkInLocal = DateTime.parse(existing.checkInAt!).toLocal();

    // 1) لا نسمح بانصراف قبل الحضور
    var checkoutLocal = rawCheckoutLocal.isBefore(checkInLocal)
        ? checkInLocal
        : rawCheckoutLocal;

    // 2) لا نسمح بانصراف في المستقبل
    final nowLocal = DateTime.now();
    if (checkoutLocal.isAfter(nowLocal)) {
      checkoutLocal = nowLocal;
    }

    return checkoutLocal;
  }
  Future<AttendanceRecordModel> checkIn() async {
    final employeeId = _authUserId();
    final schedule =
    await _scheduleRepository.getScheduleForEmployee(employeeId);

    final now = DateTime.now();
    final today = _dateOnly(now);

    final hasApprovedLeave = await _hasApprovedLeaveForDate(
      employeeId: employeeId,
      date: today,
    );

    if (hasApprovedLeave) {
      throw Exception('لديك إجازة معتمدة اليوم، لا يمكن تسجيل الحضور.');
    }

    if (!schedule.workDays.contains(now.weekday)) {
      throw Exception('اليوم ليس ضمن أيام الدوام الرسمية');
    }

    final existing = await getTodayRecord();
    if (existing != null) {
      // لو عنده حضور اليوم لكن بدون انصراف → نعيد استخدام السجل
      if (existing.checkOutAt == null) {
        final checkInStr = existing.checkInAt;

        if (checkInStr != null) {
          // نشغّل المؤقت من وقت الحضور الفعلي
          final checkInTime = DateTime.parse(checkInStr).toLocal();
          await WorkTimerService.instance.start(
            userId: employeeId,
            checkInTime: checkInTime,
          );
        }

        // نرجّع نفس السجل الموجود، بدون إنشاء واحد جديد
        return existing;
      }

      // لو لديه حضور + انصراف كامل لنفس اليوم → نمنع دوام ثاني
      throw Exception('تم تسجيل دوام كامل لهذا اليوم مسبقاً.');
    }

    int lateMinutes = 0;
    int totalLateMinutes = 0;
    int approvedLateMinutes = 0;
    int unapprovedLateMinutes = 0;
    String status = 'checked_in';

    if (schedule.scheduleType == 'fixed') {
      final officialStart = _timeToDateTimeForDate(now, schedule.startTime);
      final officialEnd = _timeToDateTimeForDate(now, schedule.endTime);

      // منع الحضور قبل بداية الدوام بأكثر من 10 دقائق
      final earliestAllowedCheckIn = officialStart.subtract(
        const Duration(minutes: _earlyCheckInAllowanceMinutes),
      );
      if (now.isBefore(earliestAllowedCheckIn)) {
        throw Exception('يمكن تسجيل الحضور قبل بداية الدوام بعشر دقائق فقط.');
      }

      if (!schedule.allowCheckInAfterEndTime && now.isAfter(officialEnd)) {
        throw Exception('لا يمكن تسجيل الحضور بعد نهاية وقت الدوام الرسمي');
      }

      if (now.isAfter(officialStart)) {
        totalLateMinutes = now.difference(officialStart).inMinutes;
      }

      final allowedStart =
      officialStart.add(Duration(minutes: schedule.graceMinutes));

      final approvedLatePermission = await _getApprovedPermission(
        employeeId: employeeId,
        date: today,
        type: 'late_arrival',
      );

      if (approvedLatePermission != null) {
        final permissionEndTime = _timeToDateTimeForDate(
          now,
          approvedLatePermission['end_time'].toString(),
        );

        final approvedEnd =
        permissionEndTime.isBefore(now) ? permissionEndTime : now;

        if (approvedEnd.isAfter(officialStart)) {
          approvedLateMinutes = approvedEnd.difference(officialStart).inMinutes;
        }

        if (approvedLateMinutes > totalLateMinutes) {
          approvedLateMinutes = totalLateMinutes;
        }

        unapprovedLateMinutes = totalLateMinutes - approvedLateMinutes;
        if (unapprovedLateMinutes < 0) {
          unapprovedLateMinutes = 0;
        }

        lateMinutes = unapprovedLateMinutes;

        if (totalLateMinutes > 0 && unapprovedLateMinutes == 0) {
          status = 'approved_late';
        } else if (unapprovedLateMinutes > 0 && approvedLateMinutes > 0) {
          status = 'partially_approved_late';
        } else if (unapprovedLateMinutes > 0) {
          status = 'late';
        }
      } else {
        if (now.isAfter(allowedStart)) {
          totalLateMinutes = now.difference(officialStart).inMinutes;
          approvedLateMinutes = 0;
          unapprovedLateMinutes = totalLateMinutes;
          lateMinutes = unapprovedLateMinutes;
          status = 'late';
        }
      }
    }

    if (schedule.scheduleType == 'hourly') {
      status = 'checked_in';
      lateMinutes = 0;
      totalLateMinutes = 0;
      approvedLateMinutes = 0;
      unapprovedLateMinutes = 0;
    }

    final rows = await _client.from('attendance_records').insert({
      'employee_id': employeeId,
      'attendance_date': today,
      'check_in_at': now.toUtc().toIso8601String(),
      'status': status,
      'late_minutes': lateMinutes,
      'total_late_minutes': totalLateMinutes,
      'approved_late_minutes': approvedLateMinutes,
      'unapproved_late_minutes': unapprovedLateMinutes,
      'early_leave_minutes': 0,
      'approved_early_leave_minutes': 0,
      'unapproved_early_leave_minutes': 0,
      'worked_minutes': 0,
      'updated_at': now.toUtc().toIso8601String(),
    }).select();

    if (rows.isEmpty) {
      throw Exception('فشل إنشاء سجل الحضور');
    }

    await WorkTimerService.instance.start(
      userId: employeeId,
      checkInTime: now,
    );
    return AttendanceRecordModel.fromJson(rows.first);
  }

  Future<void> syncMyLiveLocation({
    required double lat,
    required double lng,
  }) async {
    await _client.rpc(
      'set_my_live_location',
      params: {
        'p_lat': lat,
        'p_lng': lng,
      },
    );
  }

  Future<Map<String, dynamic>> getTodayAttendanceForEmployeeForAdmin({
    required String employeeId,
  }) async {
    final profile = await _client
        .from('profiles')
        .select('''
        id,
        full_name,
        email,
        current_lat,
        current_lng,
        current_location_updated_at
      ''')
        .eq('id', employeeId)
        .maybeSingle();

    if (profile == null) {
      throw Exception('الموظف غير موجود');
    }

    final records = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .order('created_at', ascending: false)
        .limit(1);

    final record =
    records.isNotEmpty ? Map<String, dynamic>.from(records.first) : null;

    final checkInAt = record?['check_in_at'];
    final checkOutAt = record?['check_out_at'];

    return {
      'record': record,
      'employeeId': employeeId,
      'employeeName': profile['full_name']?.toString() ?? 'غير معروف',
      'employeeEmail': profile['email']?.toString() ?? '',
      'currentLat': profile['current_lat'],
      'currentLng': profile['current_lng'],
      'locationUpdatedAt': profile['current_location_updated_at'],
      'todayStatus': record?['status']?.toString(),
      'isOnDuty': checkInAt != null && checkOutAt == null,
    };
  }


  Future<List<Map<String, dynamic>>> getTodayAttendanceForAdmin() async {
    final data = await _client
        .from('attendance_records')
        .select('''
        *,
        profiles!attendance_records_employee_id_fkey(
          id,
          full_name,
          email,
          current_lat,
          current_lng,
          current_location_updated_at
        )
      ''')
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .order('created_at', ascending: false);

    return data.map<Map<String, dynamic>>((item) {
      final profile = item['profiles'] as Map<String, dynamic>?;

      return {
        'record': item,
        'employeeId': item['employee_id'],
        'employeeName': profile?['full_name']?.toString() ?? 'غير معروف',
        'employeeEmail': profile?['email']?.toString() ?? '',
        'currentLat': profile?['current_lat'],
        'currentLng': profile?['current_lng'],
        'locationUpdatedAt': profile?['current_location_updated_at'],
      };
    }).toList();
  }

  Future<List<AttendanceRecordModel>> getEmployeeMonthlyRecordsForAdmin({
    required String employeeId,
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final data = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .gte('attendance_date', _dateOnly(start))
        .lt('attendance_date', _dateOnly(end))
        .order('attendance_date', ascending: false);

    return data
        .map<AttendanceRecordModel>((item) => AttendanceRecordModel.fromJson(item))
        .toList();
  }
  Future<AttendanceRecordModel> checkOut() async {
    final employeeId = _authUserId();

    // 1) نتأكد من وجود سجل وعدم وجود انصراف
    final existing = await getTodayRecord();
    if (existing == null || existing.checkInAt == null) {
      throw Exception('لا يوجد حضور مسجل اليوم.');
    }
    if (existing.checkOutAt != null) {
      throw Exception('تم تسجيل الانصراف مسبقاً لهذا اليوم.');
    }

    // 2) نحسب وقت الانصراف الخام (من الآن)، ثم نمرره عبر دالة الأمان
    final rawCheckoutLocal = DateTime.now();
    final safeCheckoutLocal = _safeCheckoutLocalTime(
      existing: existing,
      rawCheckoutLocal: rawCheckoutLocal,
    );

    // 3) نستدعي دالة موحدة تقوم بكل الحسابات والتحديث
    return _performCheckOut(employeeId, safeCheckoutLocal);
  }

  Future<AttendanceRecordModel> checkOutWithTime(
      DateTime actualCheckoutTime,
      ) async {
    final employeeId = _authUserId();

    final existing = await getTodayRecord();
    if (existing == null || existing.checkInAt == null) {
      throw Exception('لا يوجد حضور مسجل اليوم.');
    }
    if (existing.checkOutAt != null) {
      throw Exception('تم تسجيل الانصراف مسبقاً لهذا اليوم.');
    }

    // 1) نحول الوقت القادم من offline إلى local، ثم نحميه
    final rawCheckoutLocal = actualCheckoutTime.toLocal();
    final safeCheckoutLocal = _safeCheckoutLocalTime(
      existing: existing,
      rawCheckoutLocal: rawCheckoutLocal,
    );

    // 2) نستخدم نفس المسار الموحد
    return _performCheckOut(employeeId, safeCheckoutLocal);
  }

  Future<AttendanceRecordModel> _performCheckOut(
      String employeeId,
      DateTime checkOutTime,
      ) async {
    final existing = await getTodayRecord();

    if (existing == null) {
      throw Exception('لا يوجد تسجيل حضور لهذا اليوم');
    }

    if (existing.checkInAt == null) {
      throw Exception('سجل الحضور غير مكتمل');
    }

    if (existing.checkOutAt != null) {
      throw Exception('تم تسجيل الانصراف مسبقاً لهذا اليوم');
    }

    final schedule =
    await _scheduleRepository.getScheduleForEmployee(employeeId);

    final checkInAt = DateTime.parse(existing.checkInAt!).toLocal();

    final activeBreak = await getActiveBreak();
    if (activeBreak != null) {
      throw Exception(
        'لا يمكن إنهاء الدوام أثناء وجود راحة نشطة. يرجى إنهاء الراحة أولاً.',
      );
    }

    final todayBreaks = await getTodayBreaks();
    final totalBreakMinutes = todayBreaks.fold<int>(
      0,
          (sum, b) => sum + b.breakMinutes,
    );

    final exitReturnBreakdown = await _getTodayExitReturnUsageBreakdown(
      employeeId: employeeId,
      todayBreaks: todayBreaks,
    );

    final approvedExitReturnMinutes =
        exitReturnBreakdown['approvedMinutes'] ?? 0;
    final unapprovedExitReturnMinutes =
        exitReturnBreakdown['unapprovedMinutes'] ?? 0;

    int workedMinutes =
        checkOutTime.difference(checkInAt).inMinutes - totalBreakMinutes;
    if (workedMinutes < 0) workedMinutes = 0;
    int earlyLeaveMinutes = 0;
    int approvedEarlyLeave = 0;
    int unapprovedEarlyLeave = 0;
    String status = 'checked_out';

    if (schedule.scheduleType == 'fixed') {
      final officialEnd = _timeToDateTimeForDate(
        checkOutTime,
        schedule.endTime,
      );

      if (checkOutTime.isBefore(officialEnd)) {
        earlyLeaveMinutes = officialEnd.difference(checkOutTime).inMinutes;

        final approvedEarlyPermission = await _getApprovedPermission(
          employeeId: employeeId,
          date: _dateOnly(checkOutTime),
          type: 'early_leave',
        );

        if (approvedEarlyPermission != null) {
          final permissionStart =
          approvedEarlyPermission['start_time'].toString();

          final permissionStartMinutes = _timeToMinutes(permissionStart);
          final officialEndMinutes = _timeToMinutes(schedule.endTime);

          approvedEarlyLeave = officialEndMinutes - permissionStartMinutes;

          if (approvedEarlyLeave < 0) {
            approvedEarlyLeave = 0;
          }

          if (approvedEarlyLeave > earlyLeaveMinutes) {
            approvedEarlyLeave = earlyLeaveMinutes;
          }

          unapprovedEarlyLeave = earlyLeaveMinutes - approvedEarlyLeave;

          if (unapprovedEarlyLeave < 0) {
            unapprovedEarlyLeave = 0;
          }

          if (unapprovedEarlyLeave == 0) {
            status = 'early_leave_approved';
          } else if (approvedEarlyLeave > 0) {
            status = 'early_leave_partial';
          } else {
            status = 'early_leave';
          }
        } else {
          approvedEarlyLeave = 0;
          unapprovedEarlyLeave = earlyLeaveMinutes;
          status = 'early_leave';
        }
      } else {
        status =
        existing.lateMinutes > 0 ? 'late_checked_out' : 'checked_out';
      }
    } else if (schedule.scheduleType == 'hourly') {
      final remaining = schedule.requiredMinutes - workedMinutes;

      if (remaining > 0) {
        status = 'hours_incomplete';
      } else if (workedMinutes > schedule.requiredMinutes) {
        status = 'hours_completed_with_overtime';
      } else {
        status = 'hours_completed';
      }
    }

    String? notes = existing.notes;
    if (unapprovedExitReturnMinutes > 0) {
      final overrunNote =
          'تجاوز إذن خروج/عودة: $unapprovedExitReturnMinutes دقيقة (المعتمد: $approvedExitReturnMinutes دقيقة)';
      notes = (notes == null || notes.trim().isEmpty)
          ? overrunNote
          : '$notes | $overrunNote';
    }

    final rows = await _client
        .from('attendance_records')
        .update({
      'check_out_at': checkOutTime.toUtc().toIso8601String(),
      'worked_minutes': workedMinutes,
      'early_leave_minutes': earlyLeaveMinutes,
      'approved_early_leave_minutes': approvedEarlyLeave,
      'unapproved_early_leave_minutes': unapprovedEarlyLeave,
      'status': status,
      'notes': notes,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', existing.id)
        .select();

    if (rows.isEmpty) {
      throw Exception('فشل تحديث سجل الانصراف');
    }

    await WorkTimerService.instance.stop(userId: employeeId);

    return AttendanceRecordModel.fromJson(rows.first);
  }
  Future<List<AttendanceRecordModel>> getMyMonthlyRecords(
      DateTime month,
      ) async {
    final employeeId = _authUserId();
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);

    final data = await _client
        .from('attendance_records')
        .select()
        .eq('employee_id', employeeId)
        .gte('attendance_date', _dateOnly(start))
        .lt('attendance_date', _dateOnly(end))
        .order('attendance_date', ascending: false);

    return data
        .map<AttendanceRecordModel>(
          (item) => AttendanceRecordModel.fromJson(item),
    )
        .toList();
  }

  Future<WorkScheduleModel> getMyWorkSchedule() async {
    final employeeId = _authUserId();
    return _scheduleRepository.getScheduleForEmployee(employeeId);
  }

  Future<List<AttendanceRecordModel>> getTodayAllRecords() async {
    final data = await _client
        .from('attendance_records')
        .select()
        .eq('attendance_date', _dateOnly(DateTime.now()))
        .order('created_at', ascending: false);

    return data
        .map<AttendanceRecordModel>(
          (item) => AttendanceRecordModel.fromJson(item),
    )
        .toList();
  }

  DateTime _permissionTimeOnDate({
    required String time,
    required DateTime date,
  }) {
    final parts = time.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  Future<Map<String, dynamic>?> _getTodayApprovedExitReturnPermission({
    required String employeeId,
  }) async {
    final today = _dateOnly(DateTime.now());

    final rows = await _client
        .from('permissions')
        .select()
        .eq('employee_id', employeeId)
        .eq('permission_date', today)
        .eq('type', 'exit_return')
        .eq('status', 'approved')
        .order('created_at', ascending: false)
        .limit(1);

    if (rows.isEmpty) return null;
    return Map<String, dynamic>.from(rows.first);
  }

  Future<AttendanceBreakModel> startExitReturnPermission() async {
    final employeeId = _authUserId();
    final schedule = await _scheduleRepository.getScheduleForEmployee(employeeId);

    if (schedule.scheduleType != 'fixed') {
      throw Exception('إذن الخروج والعودة متاح حاليا للدوام الثابت فقط.');
    }

    final record = await getTodayRecord();
    if (record == null || record.checkInAt == null) {
      throw Exception('يجب تسجيل الحضور أولا قبل استخدام الإذن.');
    }

    if (record.checkOutAt != null) {
      throw Exception('تم إنهاء الدوام بالفعل.');
    }

    final activeBreak = await getActiveBreak();
    if (activeBreak != null) {
      throw Exception('يوجد إذن/استراحة نشطة بالفعل. أنهها أولا.');
    }

    final permission = await _getTodayApprovedExitReturnPermission(
      employeeId: employeeId,
    );

    if (permission == null) {
      throw Exception('لا يوجد إذن خروج وعودة معتمد لهذا اليوم.');
    }

    final now = DateTime.now();
    final permissionStart = _permissionTimeOnDate(
      time: permission['start_time'].toString(),
      date: now,
    );
    final permissionEnd = _permissionTimeOnDate(
      time: permission['end_time'].toString(),
      date: now,
    );

    if (now.isBefore(permissionStart) || now.isAfter(permissionEnd)) {
      throw Exception('يمكن بدء الإذن فقط خلال الفترة الزمنية المعتمدة.');
    }

    final rows = await _client.from('attendance_breaks').insert({
      'attendance_record_id': record.id,
      'employee_id': employeeId,
      'break_start_at': now.toUtc().toIso8601String(),
      'status': 'active',
      'break_minutes': 0,
      'updated_at': now.toUtc().toIso8601String(),
    }).select();

    if (rows.isEmpty) {
      throw Exception('فشل بدء استخدام إذن الخروج والعودة.');
    }

    return AttendanceBreakModel.fromJson(rows.first);
  }

  Future<AttendanceBreakModel> endExitReturnPermission() async {
    final activeBreak = await getActiveBreak();

    if (activeBreak == null) {
      throw Exception('لا يوجد إذن خروج وعودة نشط حاليا.');
    }

    final now = DateTime.now();
    final start = DateTime.parse(activeBreak.breakStartAt).toLocal();

    int minutes = now.difference(start).inMinutes;
    if (minutes < 0) minutes = 0;

    final rows = await _client
        .from('attendance_breaks')
        .update({
      'break_end_at': now.toUtc().toIso8601String(),
      'break_minutes': minutes,
      'status': 'ended',
      'updated_at': now.toUtc().toIso8601String(),
    })
        .eq('id', activeBreak.id)
        .select();

    if (rows.isEmpty) {
      throw Exception('فشل إنهاء إذن الخروج والعودة.');
    }

    return AttendanceBreakModel.fromJson(rows.first);
  }

}

