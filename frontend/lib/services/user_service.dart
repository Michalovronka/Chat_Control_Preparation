import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_state.dart';

class UserService {
  static const String baseUrl = 'http://localhost:5202/api/user';

  // Create a new user
  static Future<Map<String, dynamic>?> createUser({String? userId, String? userName}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserId': userId,
          'UserName': userName,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to create user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  // Get user by ID
  static Future<Map<String, dynamic>?> getUser(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to get user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Initialize user (create if doesn't exist, or get if exists)
  static Future<bool> initializeUser(String userId, String userName) async {
    final appState = AppState();
    
    // Try to get existing user first
    final existingUser = await getUser(userId);
    if (existingUser != null) {
      appState.setUser(userId, existingUser['UserName'] ?? userName);
      return true;
    }

    // Create new user
    final newUser = await createUser(userId: userId, userName: userName);
    if (newUser != null) {
      appState.setUser(newUser['UserId'] ?? userId, newUser['UserName'] ?? userName);
      return true;
    }

    return false;
  }
}
