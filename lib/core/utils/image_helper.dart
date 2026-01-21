// Helper for image picking
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<XFile?> pickImageFromGallery() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.gallery);
  }

  static Future<XFile?> pickImageFromCamera() async {
    final picker = ImagePicker();
    return await picker.pickImage(source: ImageSource.camera);
  }
}
