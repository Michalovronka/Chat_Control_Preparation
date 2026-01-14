import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class ImageService {
  static const String baseUrl = 'http://localhost:5202/api/image';

  // Upload image to server
  static Future<String?> uploadImage(XFile imageFile) async {
    try {
      // Read image bytes (works on all platforms including web)
      final imageBytes = await imageFile.readAsBytes();
      
      // Get file name
      final fileName = imageFile.name;

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final result = jsonDecode(responseBody) as Map<String, dynamic>;
        final imagePath = result['ImagePath'] ?? result['imagePath'];
        return imagePath?.toString();
      } else {
        print('Failed to upload image: ${response.statusCode} - $responseBody');
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Get full image URL
  static String getImageUrl(String imagePath) {
    // If already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    // Otherwise, construct full URL
    if (imagePath.startsWith('/')) {
      return 'http://localhost:5202$imagePath';
    }
    return 'http://localhost:5202/api/image/$imagePath';
  }
}
