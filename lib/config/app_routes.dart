// App routes configuration
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../splash/splash_page.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/register_page.dart';
import '../modules/auth/forgot_password_page.dart';
import '../modules/auth/profile_page.dart';
import '../modules/reports/dashboard_page.dart';
import '../modules/reports/create_report_page.dart';
import '../modules/reports/report_detail_page.dart';
import '../modules/reports/report_model.dart';
import '../modules/map/map_page.dart';
import '../modules/auth/reset_password_page.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/forgot',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          final supabase = Supabase.instance.client;
          if (supabase.auth.currentUser == null) {
            // Si no está autenticado, redirige al login
            return const LoginPage();
          }
          return const DashboardPage();
        },
      ),
      GoRoute(
        path: '/create',
        builder: (context, state) {
          final report = state.extra as Report?;
          return CreateReportPage(reportToEdit: report);
        },
      ),
      GoRoute(
        path: '/detail',
        builder: (context, state) {
          final report = state.extra as Report?;
          if (report == null) return const Scaffold(body: Center(child: Text('Reporte no encontrado')));
          return ReportDetailPage(report: report);
        },
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) => const MapPage(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          // Siempre muestra el formulario de recuperación
          return const ResetPasswordPage();
        },
      ),
    ],
  );
}
