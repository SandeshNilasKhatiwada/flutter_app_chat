import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaver {
  // Convert Base64 string to File, save it to the gallery, and return file path
  static Future<String?> saveImageToGallery(String base64String) async {
    try {
      // Request gallery permissions
      if (!await Gal.hasAccess()) {
        print('No permission');
        final access = await Gal.requestAccess();
        print('Access success: $access');
      }

      // Decode Base64 string to bytes
      Uint8List bytesData = base64Decode(base64String);

      // Get the directory to store the image
      Directory? directory =
          await getTemporaryDirectory(); // or getApplicationDocumentsDirectory()
      String filePath =
          '${directory.path}/saved_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Save the file
      File file = File(filePath);
      await file.writeAsBytes(bytesData);

      // Save image to gallery
      await Gal.putImage(filePath);

      print("✅ Image saved successfully at: ${file.path}");
      return filePath;
    } catch (e) {
      print("❌ Error saving image to gallery: $e");
      return null;
    }
  }
}
