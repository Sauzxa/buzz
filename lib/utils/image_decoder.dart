import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

class ImageDecoder {
  /// Decode base64 string to Uint8List asynchronously using a background isolate
  static Future<Uint8List?> decodeBase64Image(String? base64String) async {
    if (base64String == null || base64String.isEmpty) {
      return null;
    }
    try {
      return await compute(_decodeIso, base64String);
    } catch (e) {
      print('Error decoding base64 image async: $e');
      return null;
    }
  }

  /// The function that runs in the isolate
  static Uint8List? _decodeIso(String base64String) {
    try {
      // Remove data:image prefix if present
      String cleanBase64 = base64String;
      if (base64String.contains(',')) {
        cleanBase64 = base64String.split(',').last;
      }

      // Clean up any newlines or whitespace
      cleanBase64 = cleanBase64.replaceAll(RegExp(r'\s+'), '');

      // Decode base64 to bytes
      return base64Decode(cleanBase64);
    } catch (e) {
      print('Error in isolate decoding: $e');
      return null;
    }
  }

  /// Synchronous fallback if needed (kept for compatibility, but prefer async)
  static Uint8List? decodeBase64ImageSync(String? base64String) {
    return _decodeIso(base64String ?? '');
  }

  /// Check if base64 string is valid
  static bool isValidBase64(String? base64String) {
    if (base64String == null || base64String.isEmpty) {
      return false;
    }
    try {
      _decodeIso(base64String);
      return true;
    } catch (e) {
      return false;
    }
  }
}
