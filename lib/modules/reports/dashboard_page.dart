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
    _loadReports();
  }

  void _loadReports() {
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _futureReports = user != null
          ? ReportService().getUserReports(user.id)
          : Future.value([]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si se navega con el parámetro 'refresh', recargar la lista automáticamente
    // Para refrescar la lista, usar setState en el callback de Navigator
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
              String estadoFormal;
              switch (r.estado) {
                case 'pendiente':
                  estadoFormal = 'Pendiente';
                  break;
                case 'en_proceso':
                  estadoFormal = 'En proceso';
                  break;
                case 'resuelto':
                  estadoFormal = 'Resuelto';
                  break;
                default:
                  estadoFormal = r.estado;
              }
              return ListTile(
                title: Text(r.titulo),
                subtitle: Text(r.categoria),
                trailing: Text(estadoFormal),
                onTap: () {
                  context.push('/detail', extra: r);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/create');
          if (result == true) {
            _loadReports();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
