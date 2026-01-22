import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../config/api_config.dart';

class ImageService {
  static String get baseUrl => ApiConfig.getApiUrl('image');

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
    // If already a full URL, replace localhost/127.0.0.1 with platform-specific base URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      // Replace localhost/127.0.0.1 with platform-specific base URL for mobile compatibility
      final uri = Uri.parse(imagePath);
      if (uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host == '0.0.0.0') {
        // Extract the path and reconstruct with platform-specific base URL
        final path = uri.path;
        return '${ApiConfig.baseUrl}$path${uri.hasQuery ? '?${uri.query}' : ''}';
      }
      // If it's already a proper URL (not localhost), return as is
      return imagePath;
    }
    // Otherwise, construct full URL from relative path
    if (imagePath.startsWith('/')) {
      return '${ApiConfig.baseUrl}$imagePath';
    }
    return '${ApiConfig.getApiUrl('image')}/$imagePath';
  }
}
