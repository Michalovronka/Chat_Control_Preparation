import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.getApiUrl('auth');

  // Register a new user
  static Future<Map<String, dynamic>?> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': username,
          'Password': password,
        }),
      );

      print('Register response status: ${response.statusCode}'); // Debug
      print('Register response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        print('Registration response decoded: $decoded'); // Debug
        return decoded;
      } else {
        // Handle error response
        String errorMessage = 'Registration failed';
        try {
          if (response.body.isNotEmpty) {
            final error = jsonDecode(response.body);
            errorMessage = error['Error']?.toString() ?? errorMessage;
          }
        } catch (e) {
          // If JSON parsing fails, use status code message
          if (response.statusCode == 400) {
            errorMessage = 'Invalid request';
          }
        }
        print('Failed to register: ${response.statusCode} - $errorMessage');
        return {'error': errorMessage};
      }
    } catch (e) {
      print('Error registering: $e');
      return {'error': 'Connection error: $e'};
    }
  }

  // Login user
  static Future<Map<String, dynamic>?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Username': username,
          'Password': password,
        }),
      );

      print('Login response status: ${response.statusCode}'); // Debug
      print('Login response body: ${response.body}'); // Debug

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        print('Login response decoded: $decoded'); // Debug
        return decoded;
      } else {
        // Handle error response
        String errorMessage = 'Login failed';
        try {
          if (response.body.isNotEmpty) {
            final error = jsonDecode(response.body);
            errorMessage = error['Error']?.toString() ?? errorMessage;
          }
        } catch (e) {
          // If JSON parsing fails, use status code message
          if (response.statusCode == 401) {
            errorMessage = 'Invalid username or password';
          } else if (response.statusCode == 400) {
            errorMessage = 'Invalid request';
          }
        }
        print('Failed to login: ${response.statusCode} - $errorMessage');
        return {'error': errorMessage};
      }
    } catch (e) {
      print('Error logging in: $e');
      return {'error': 'Connection error: $e'};
    }
  }
}
