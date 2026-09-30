import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/routing/app_router.dart';
import '../core/theme/cl_theme.dart';

class CasaLazzariniApp extends ConsumerWidget {
  const CasaLazzariniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Casa Lazzarini',
      theme: CLTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
