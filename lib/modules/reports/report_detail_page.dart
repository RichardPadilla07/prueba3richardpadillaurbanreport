import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'report_model.dart';
import 'report_service.dart';
import '../../core/widgets/custom_button.dart';

class ReportDetailPage extends StatefulWidget {
  final Report report;
  const ReportDetailPage({super.key, required this.report});

  @override
  State<ReportDetailPage> createState() => _ReportDetailPageState();
}

class _ReportDetailPageState extends State<ReportDetailPage> {
    void _edit() async {
      // Navegar a la pantalla de crear reporte en modo edición (puedes crear una pantalla separada si lo prefieres)
      context.push('/create', extra: widget.report);
    }
  bool _loading = false;
  String? _error;
  String? _selectedEstado;

  void _delete() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ReportService().deleteReport(widget.report.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reporte eliminado exitosamente')),
        );
        // Volver a la lista y refrescar automáticamente
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() { _error = 'Error al eliminar'; });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.report;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reporte')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 32),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.assignment, color: theme.colorScheme.primary, size: 32),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        r.titulo,
                        style: theme.textTheme.headlineMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (r.fotoUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(r.fotoUrl, height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.category, color: theme.colorScheme.secondary, size: 22),
                    const SizedBox(width: 6),
                    Text(r.categoria, style: theme.textTheme.bodyLarge),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.secondary, size: 22),
                    const SizedBox(width: 6),
                    Text(
                      r.estado[0].toUpperCase() + r.estado.substring(1),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: r.estado.toLowerCase() == 'resuelto'
                            ? Colors.green[700]
                            : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: theme.colorScheme.secondary, size: 20),
                    const SizedBox(width: 6),
                    Text('${r.createdAt}', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(height: 14),
                Text('Descripción', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(r.descripcion, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Editar',
                        onPressed: _edit,
                        loading: false,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        text: 'Eliminar',
                        onPressed: _delete,
                        loading: _loading,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
