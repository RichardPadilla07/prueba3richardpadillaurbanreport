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
        context.pop();
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
    _selectedEstado ??= r.estado;
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Reporte')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Título: ${r.titulo}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Descripción: ${r.descripcion}'),
            Text('Categoría: ${r.categoria}'),
            Row(
              children: [
                const Text('Estado: '),
                DropdownButton<String>(
                  value: _selectedEstado,
                  items: const [
                    DropdownMenuItem(value: 'pendiente', child: Text('Pendiente')),
                    DropdownMenuItem(value: 'en_proceso', child: Text('En proceso')),
                    DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                  ],
                  onChanged: (value) async {
                    if (value != null && value != r.estado) {
                      setState(() { _selectedEstado = value; _loading = true; });
                      final updated = r.copyWith(estado: value);
                      try {
                        await ReportService().updateReport(updated);
                        setState(() { _loading = false; });
                      } catch (e) {
                        setState(() { _error = 'Error al cambiar estado'; _loading = false; });
                      }
                    }
                  },
                ),
                if (_loading) const SizedBox(width: 8),
                if (_loading) const CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
            Text('Fecha: ${r.createdAt}'),
            if (r.fotoUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Image.network(r.fotoUrl, height: 200),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Editar',
                    onPressed: _edit,
                    loading: false,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Eliminar',
                    onPressed: _delete,
                    loading: _loading,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
