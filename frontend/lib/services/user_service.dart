import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_state.dart';
import '../config/api_config.dart';

class UserService {
  static String get baseUrl => ApiConfig.getApiUrl('user');

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

  // Get user by username
  static Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      final encodedUsername = Uri.encodeComponent(username);
      final response = await http.get(
        Uri.parse('$baseUrl/by-username/$encodedUsername'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to get user by username: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting user by username: $e');
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

  // Get users in a room
  static Future<List<dynamic>?> getUsersByRoom(String roomId) async {
    try {
      final encodedRoomId = Uri.encodeComponent(roomId);
      final response = await http.get(
        Uri.parse('$baseUrl/room/$encodedRoomId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Failed to get users in room: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting users in room: $e');
      return null;
    }
  }

  // Update user
  static Future<Map<String, dynamic>?> updateUser({
    required String userId,
    String? userName,
    String? statusMessage,
    String? userState,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'UserName': userName,
          'StatusMessage': statusMessage,
          'UserState': userState,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to update user: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error updating user: $e');
      return null;
    }
  }

  // Get blocked users for a user
  static Future<List<String>?> getBlockedUsers(String userId) async {
    try {
      final encodedUserId = Uri.encodeComponent(userId);
      final response = await http.get(
        Uri.parse('$baseUrl/$encodedUserId/blocked-users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as List<dynamic>;
        return result.map((id) => id.toString()).toList();
      } else {
        print('Failed to get blocked users: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting blocked users: $e');
      return null;
    }
  }
}
