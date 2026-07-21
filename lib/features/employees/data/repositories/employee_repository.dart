import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/employee_model.dart';

class EmployeeRepository {
  final SupabaseClient _client;

  EmployeeRepository(this._client);

  Future<List<EmployeeModel>> getAllEmployees() async {
    final data = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);

    return data.map<EmployeeModel>((item) {
      return EmployeeModel.fromJson(item);
    }).toList();
  }
  Future<void> updateEmployeeWorkSchedule({
    required String employeeId,
    required String? workScheduleId,
  }) async {
    await _client
        .from('profiles')
        .update({
      'work_schedule_id': workScheduleId,
    })
        .eq('id', employeeId);
  }
  Future<void> activateEmployee(String id) async {
    await _client
        .from('profiles')
        .update({'is_active': true})
        .eq('id', id);
  }

  Future<void> deactivateEmployee(String id) async {
    await _client
        .from('profiles')
        .update({'is_active': false})
        .eq('id', id);
  }


}