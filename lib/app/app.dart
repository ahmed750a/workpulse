import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/providers/auth_provider.dart';
import 'router/app_router.dart';

class WorkPulseApp extends ConsumerStatefulWidget {
  const WorkPulseApp({super.key});

  @override
  ConsumerState<WorkPulseApp> createState() => _WorkPulseAppState();
}

class _WorkPulseAppState extends ConsumerState<WorkPulseApp> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(authProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(

      title: 'WorkPulse',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: ref.watch(appRouterProvider),    );
  }
}