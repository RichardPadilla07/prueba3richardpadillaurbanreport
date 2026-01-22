import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'report_model.dart';
import 'report_service.dart';
import '../../modules/auth/auth_service.dart';
import '../../core/widgets/custom_button.dart';

class ReportDetailPage extends StatefulWidget {
  final Report report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
  bool _loading = false;
  String? _error;

  void _edit() {
    context.push('/create', extra: widget.report);
  }

  Future<void> _delete() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ReportService().deleteReport(widget.report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reporte eliminado exitosamente')));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al eliminar';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _openImage(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.of(ctx).pop(),
          child: Hero(
            tag: 'report-image-${widget.report.id}',
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  );
                },
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey.shade100,
                  child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final theme = Theme.of(context);
    final currentUser = AuthService().currentUser;
    final bool isAuthor = currentUser != null && currentUser.id == r.usuarioId;
    final String authorName = isAuthor ? (currentUser.userMetadata?['name'] ?? currentUser.email ?? r.usuarioId) : r.usuarioId;

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

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.assignment, color: theme.colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(r.titulo, style: theme.textTheme.headlineMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Image larger and responsive; tap to view full image
                    if (r.fotoUrl.isNotEmpty)
                      GestureDetector(
                        onTap: () => _openImage(r.fotoUrl),
                        child: Hero(
                          tag: 'report-image-${r.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: double.infinity,
                              height: 220,
                              child: Container(
                                color: Colors.grey.shade100,
                                padding: const EdgeInsets.all(6),
                                child: Center(
                                  child: Image.network(
                                    r.fotoUrl,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                              : null,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      );
                                    },
                                    errorBuilder: (c, e, s) => Container(
                                      color: Colors.grey.shade100,
                                      child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.black26)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 16),
                    // Author, category
                    Row(
                      children: [
                        CircleAvatar(radius: 18, backgroundColor: Colors.grey.shade100, child: const Icon(Icons.person, color: Colors.black54)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(authorName, style: theme.textTheme.titleLarge?.copyWith(color: Colors.black))),
                        const SizedBox(width: 12),
                        Text(r.categoria, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      ],
                    ),

                    const SizedBox(height: 12),
                    // Estado and date
                    Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20, color: Colors.black87),
                        const SizedBox(width: 8),
                        Builder(builder: (ctx) {
                          if (r.estado == 'pendiente') {
                            return Chip(
                              backgroundColor: theme.colorScheme.secondary,
                              label: Text(estadoFormal, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
                            );
                          } else if (r.estado == 'en_proceso') {
                            return Chip(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: theme.colorScheme.secondary, width: 1.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              label: Text(estadoFormal, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w700)),
                            );
                          } else {
                            return Chip(
                              backgroundColor: theme.colorScheme.primary,
                              label: Text(estadoFormal, style: TextStyle(color: theme.colorScheme.secondary, fontWeight: FontWeight.w700)),
                            );
                          }
                        }),
                        const SizedBox(width: 16),
                        const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                        const SizedBox(width: 6),
                        Text(r.createdAt.toIso8601String(), style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                      ],
                    ),

                    const SizedBox(height: 18),
                    Text('Descripción', style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
                    const SizedBox(height: 8),
                    Text(r.descripcion, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black87)),

                    const SizedBox(height: 18),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Detalles', style: theme.textTheme.titleLarge?.copyWith(color: Colors.black)),
                    const SizedBox(height: 10),
                    Wrap(
                      runSpacing: 8,
                      spacing: 12,
                      children: [
                        _metaChip(Icons.title, 'titulo', r.titulo),
                        _metaChip(Icons.category, 'categoria', r.categoria),
                        _metaChip(Icons.flag, 'estado', r.estado),
                        _metaChip(Icons.location_on, 'latitud', r.latitud.toString()),
                        _metaChip(Icons.location_on, 'longitud', r.longitud.toString()),
                        _metaChip(Icons.access_time, 'fecha_hora', r.createdAt.toIso8601String()),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Editar',
                            onPressed: _edit,
                            loading: false,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'Eliminar',
                            onPressed: _delete,
                            loading: _loading,
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),

                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12.0),
                        child: Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _metaChip(IconData icon, String label, String value) {
  return Chip(
    backgroundColor: Colors.grey.shade100,
    avatar: Icon(icon, size: 16, color: Colors.black54),
    label: Text('$label: $value', style: const TextStyle(color: Colors.black87)),
  );
}

