// Main app widget and navigation setup will be here.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'config/app_routes.dart';
import 'config/theme.dart';

class UrbanReportApp extends StatefulWidget {
  const UrbanReportApp({super.key});

  @override
  State<UrbanReportApp> createState() => _UrbanReportAppState();
}

class _UrbanReportAppState extends State<UrbanReportApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    // Listen for incoming deep links while the app is running
    _sub = _appLinks.uriLinkStream.listen((uri) {
      _handleIncomingUri(uri);
    }, onError: (err) {
      // ignore
    });
    // Handle cold start deep link
    _checkInitialUri();
  }

  Future<void> _checkInitialUri() async {
    // For web/cold start fallback we use Uri.base which usually contains query params when opened from a link.
    try {
      _handleIncomingUri(Uri.base);
    } catch (e) {
      // ignore
    }
  }

  void _handleIncomingUri(Uri? uri) {
    if (uri == null) return;
    // Expecting: urbanreport://reset-password?code=... or ?access_token=...
    if (uri.scheme == 'urbanreport' && uri.host == 'reset-password') {
      final code = uri.queryParameters['code'] ?? uri.queryParameters['access_token'] ?? uri.queryParameters['token'];
      if (code != null && code.isNotEmpty) {
        AppRoutes.router.go('/reset-password?code=$code');
      } else {
        AppRoutes.router.go('/reset-password');
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

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
