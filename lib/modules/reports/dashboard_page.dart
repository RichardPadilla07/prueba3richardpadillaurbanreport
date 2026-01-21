import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'report_service.dart';
import 'report_model.dart';
import '../../core/widgets/loading_indicator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<List<Report>> _futureReports;

  @override
  void initState() {
    super.initState();
    final user = Supabase.instance.client.auth.currentUser;
    _futureReports = user != null ? ReportService().getUserReports(user.id) : Future.value([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: 'Ver mapa',
            onPressed: () => context.push('/map'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Perfil',
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: FutureBuilder<List<Report>>(
        future: _futureReports,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar reportes'));
          }
          final reports = snapshot.data ?? [];
          if (reports.isEmpty) {
            return const Center(child: Text('No tienes reportes aún.'));
          }
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, i) {
              final r = reports[i];
              return ListTile(
                title: Text(r.titulo),
                subtitle: Text(r.categoria),
                trailing: Text(r.estado),
                onTap: () {
                  context.push('/detail', extra: r);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/create');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
