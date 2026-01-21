// Helper for image picking
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  static Future<XFile?> pickImageFromGallery() async {
    final status = await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.gallery);
    }
    return null;
  }

  static Future<XFile?> pickImageFromCamera() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      return await picker.pickImage(source: ImageSource.camera);
    }
    return null;
  }
}
