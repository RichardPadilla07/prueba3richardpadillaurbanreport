// Helper para subir imágenes a Supabase Storage
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageHelper {
  // Sube una imagen al bucket "report-images" y devuelve la URL pública
  static Future<String?> uploadImage(XFile xfile, String userId) async {
    final storage = Supabase.instance.client.storage;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${xfile.name}';
    final path = 'reportes/$userId/$fileName';

    try {
      if (kIsWeb) {
        // En web se suben bytes directamente
        final bytes = await xfile.readAsBytes();
        await storage.from('report-images').uploadBinary(path, bytes);
      } else {
        // En móviles/escritorio podemos usar File del sistema
        final file = File(xfile.path);
        await storage.from('report-images').upload(path, file);
      }

      final url = storage.from('report-images').getPublicUrl(path);
      return url;
    } catch (_) {
      return null;
    }
  }
}
