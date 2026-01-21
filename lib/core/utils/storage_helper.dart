// Helper para subir imágenes a Supabase Storage
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageHelper {
  static Future<String?> uploadImage(File file, String userId) async {
    final storage = Supabase.instance.client.storage;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final path = 'reportes/$userId/$fileName';
    final res = await storage.from('reportes').upload(path, file);
    if (res.isEmpty) return null;
    final url = storage.from('reportes').getPublicUrl(path);
    return url;
  }
}
