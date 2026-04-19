import 'package:flutter/material.dart';

import 'core/data/app_store_scope.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class FlowSenseApp extends StatelessWidget {
  const FlowSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appStore,
      builder: (context, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'FlowSense',
          theme: AppEnterpriseTheme.light(),
          darkTheme: AppEnterpriseTheme.dark(),
          themeMode: appStore.themeMode,
          scrollBehavior: const AppScrollBehavior(),
          routerConfig: appRouter,
        );
      },
    );
  }
}
