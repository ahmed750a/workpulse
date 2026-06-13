import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/work_schedule_model.dart';

class WorkScheduleRepository {
  final SupabaseClient _client;

  WorkScheduleRepository(this._client);

  Future<WorkScheduleModel> getDefaultSchedule() async {
    final data = await _client
        .from('work_schedules')
        .select()
        .eq('is_default', true)
        .single();

    return WorkScheduleModel.fromJson(data);
  }

  Future<WorkScheduleModel> getScheduleForEmployee(String employeeId) async {
    final profile = await _client
        .from('profiles')
        .select('work_schedule_id')
        .eq('id', employeeId)
        .maybeSingle();

    final scheduleId = profile?['work_schedule_id'];

    if (scheduleId == null) {
      return getDefaultSchedule();
    }

    final data = await _client
        .from('work_schedules')
        .select()
        .eq('id', scheduleId)
        .single();

    return WorkScheduleModel.fromJson(data);
  }
}