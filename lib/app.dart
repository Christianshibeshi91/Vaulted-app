import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/vaulted_theme.dart';

/// Root application widget.
///
/// Uses [ConsumerWidget] so the router (which depends on auth state)
/// rebuilds when providers change.
class VaultedApp extends ConsumerWidget {
  const VaultedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Vaulted',
      debugShowCheckedModeBanner: false,
      theme: VaultedTheme.dark(),
      routerConfig: router,
    );
  }
}
