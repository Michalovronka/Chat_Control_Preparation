import 'dart:convert';
import 'package:http/http.dart' as http;

class RoomService {
  static const String baseUrl = 'http://localhost:5202/api/room';

  // Create a new room
  static Future<Map<String, dynamic>?> createRoom({String? roomId, String? roomName, String? password}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/create'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'RoomId': roomId,
          'RoomName': roomName,
          'Password': password,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body) as Map<String, dynamic>;
        print('RoomService.createRoom response: $result');
        return result;
      } else {
        print('Failed to create room: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error creating room: $e');
      return null;
    }
  }

  // Get room by ID
  static Future<Map<String, dynamic>?> getRoom(String roomId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$roomId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to get room: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting room: $e');
      return null;
    }
  }

  // Get room by invite code
  static Future<Map<String, dynamic>?> getRoomByCode(String code) async {
    try {
      // URL encode the code to handle special characters
      final encodedCode = Uri.encodeComponent(code);
      final response = await http.get(
        Uri.parse('$baseUrl/by-code/$encodedCode'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Failed to get room by code: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting room by code: $e');
      return null;
    }
  }

  // Get all rooms
  static Future<List<dynamic>?> getAllRooms() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Failed to get rooms: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error getting rooms: $e');
      return null;
    }
  }
}
