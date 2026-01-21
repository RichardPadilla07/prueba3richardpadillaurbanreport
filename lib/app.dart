// Main app widget and navigation setup will be here.
import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'config/theme.dart';

class UrbanReportApp extends StatelessWidget {
  const UrbanReportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'UrbanReport',
      theme: AppTheme.lightTheme,
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
