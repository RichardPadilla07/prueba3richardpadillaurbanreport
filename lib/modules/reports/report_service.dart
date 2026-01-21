import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_model.dart';

class ReportService {
  final _client = Supabase.instance.client;
  final String table = 'reports';

  Future<List<Report>> getUserReports(String userId) async {
    final res = await _client.from(table).select().eq('usuario_id', userId).order('created_at', ascending: false);
    return (res as List).map((e) => Report.fromMap(e)).toList();
  }

  Future<List<Report>> getUnresolvedReports() async {
    final res = await _client.from(table).select().not('estado', 'eq', 'resuelto');
    return (res as List).map((e) => Report.fromMap(e)).toList();
  }

  Future<void> createReport(Report report) async {
    // Al crear un reporte dejamos que Supabase genere el UUID,
    // por eso removemos "id" si viene vacío.
    final data = report.toMap();
    final id = data['id'];
    if (id == null || (id is String && id.isEmpty)) {
      data.remove('id');
    }
    await _client.from(table).insert(data);
  }

  Future<void> updateReport(Report report) async {
    await _client.from(table).update(report.toMap()).eq('id', report.id);
  }

  Future<void> deleteReport(String id) async {
    await _client.from(table).delete().eq('id', id);
  }
}
