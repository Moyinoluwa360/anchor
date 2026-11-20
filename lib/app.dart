import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

class AnchorApp extends ConsumerWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(settingsProvider.select((s) => s.themeMode));
    final router = ref.watch(routerProvider);
    // Keep scheduled notifications in step with the data, and route taps.
    ref.listen(notificationSyncProvider, (_, _) {});
    ref.read(notificationServiceProvider).onTap = (payload) => router.go(routeForPayload(payload));
    return MaterialApp.router(
      title: 'Anchor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      routerConfig: router,
    );
  }
}
