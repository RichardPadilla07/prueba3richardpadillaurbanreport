import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'report_service.dart';
import 'report_model.dart';
import '../../core/widgets/loading_indicator.dart';
import 'report_detail_page.dart' show capitalize;
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
          return RefreshIndicator(
            onRefresh: () async => _loadReports(),
            child: LayoutBuilder(builder: (context, constraints) {
              final width = constraints.maxWidth;
              int columns = 1;
              if (width > 1100) {
                columns = 3;
              } else if (width > 700) {
                columns = 2;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 3.5,
                ),
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

                  return Material(
                    color: Theme.of(context).cardTheme.color,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => context.push('/detail', extra: r),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Leading image (if exists) or placeholder icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: r.fotoUrl.isNotEmpty
                                    ? Image.network(
                                        r.fotoUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, color: Colors.black26)),
                                      )
                                    : const Center(child: Icon(Icons.report, color: Colors.black54)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title and category
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(r.titulo, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black)),
                                  const SizedBox(height: 6),
                                  Text(capitalize(r.categoria), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                                  const SizedBox(height: 6),
                                  if (r.descripcion.isNotEmpty)
                                    Text(
                                      r.descripcion,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Estado chip (palette: black / white / yellow)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Builder(builder: (ctx) {
                                  // Map estados to a palette that matches black/white/yellow
                                  if (r.estado == 'pendiente') {
                                    return Chip(
                                      backgroundColor: Theme.of(context).colorScheme.secondary, // yellow
                                      label: Text(estadoFormal, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                                    );
                                  } else if (r.estado == 'en_proceso') {
                                    return Chip(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.6),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      label: Text(estadoFormal, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700)),
                                    );
                                  } else {
                                    // resuelto and others -> black background with yellow text
                                    return Chip(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      label: Text(estadoFormal, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.w700)),
                                    );
                                  }
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
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
