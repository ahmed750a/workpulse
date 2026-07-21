import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// ✅ Riverpod 3.x: StateProvider محذوف، نستخدم NotifierProvider
class SessionVersionNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final sessionVersionProvider = NotifierProvider<SessionVersionNotifier, int>(
  SessionVersionNotifier.new,
);