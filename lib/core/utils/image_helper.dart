// Helper for image picking
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<XFile?> pickImageFromGallery() async {
    final picker = ImagePicker();
    // Solicitar permiso de galería
    final permission = await picker.requestPermission();
    if (permission != null && permission) {
      return await picker.pickImage(source: ImageSource.gallery);
    }
    return null;
  }

  static Future<XFile?> pickImageFromCamera() async {
    final picker = ImagePicker();
    // Solicitar permiso de cámara
    final permission = await picker.requestPermission();
    if (permission != null && permission) {
      return await picker.pickImage(source: ImageSource.camera);
    }
    return null;
  }
}
