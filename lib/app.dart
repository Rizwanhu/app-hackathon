import 'package:flutter/material.dart';

import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';

class FlowSenseApp extends StatelessWidget {
  const FlowSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FlowSense',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}

