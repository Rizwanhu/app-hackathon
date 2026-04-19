import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/data/app_store_scope.dart';
import 'core/router/app_router.dart';

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
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            scaffoldBackgroundColor: AppColors.background,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              brightness: Brightness.dark,
            ),
          ),
          themeMode: appStore.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
