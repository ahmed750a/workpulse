import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ✅ أضف هذا
import 'package:go_router/go_router.dart';

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

    final router = ref.watch(appRouterProvider);

    ref.listen<AuthState>(authProvider, (previous, next) {
      final user = next.user;

      if (user == null) {
        router.go('/login');
      } else {
        if (user.role == 'admin') {
          router.go('/admin');
        } else {
          router.go('/employee');
        }
      }
    });

    return MaterialApp.router(
      title: 'WorkPulse',
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      routerConfig: router,
    );
  }
}