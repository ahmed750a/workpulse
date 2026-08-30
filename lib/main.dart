import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'app/app.dart';
import 'core/config/supabase_keys.dart';
import 'core/services/work_timer_service.dart';
import 'core/services/location_tracking_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  FirebaseCrashlytics.instance.log('App started');
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  await Supabase.initialize(
    url: SupabaseKeys.url,
    publishableKey: SupabaseKeys.anonKey,
  );

  // Important: initialize local notifications before any timer notification is shown.
  await WorkTimerService.instance.init();
  await LocationTrackingService.instance.init();

  runApp(
    const ProviderScope(
      child: WorkPulseApp(),
    ),
  );
}