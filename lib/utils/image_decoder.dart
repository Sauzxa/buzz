import 'dart:convert';
import 'dart:typed_data';

class ImageDecoder {
  /// Decode base64 string to Uint8List for Image.memory
  static Uint8List? decodeBase64Image(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }

    try {
      // Remove data:image prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      // Decode base64 to bytes
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Error decoding base64 image: $e');
      return null;
    }
  }

  /// Check if base64 string is valid
  static bool isValidBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return false;
    }

    try {
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }
      base64Decode(cleanBase64);
      return true;
    } catch (e) {
      return false;
    }
  }
}
