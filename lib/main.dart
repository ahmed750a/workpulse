import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';
import 'core/config/supabase_keys.dart';
import 'core/services/work_timer_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseKeys.url,
    publishableKey: SupabaseKeys.anonKey,
  );
  await WorkTimerService.instance.init();
  await WorkTimerService.instance.restoreIfActive();
  runApp(

      const ProviderScope(
          child: WorkPulseApp()));
}