import 'dart:math';

/// Simple state management for current user and room
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? _currentUserId;
  String? _currentRoomId;
  String? _currentUserName;

  String? get currentUserId => _currentUserId;
  String? get currentRoomId => _currentRoomId;
  String? get currentUserName => _currentUserName;

  void setUser(String userId, String userName) {
    _currentUserId = userId;
    _currentUserName = userName;
  }

  void setRoom(String roomId) {
    _currentRoomId = roomId;
  }

  void clearRoom() {
    _currentRoomId = null;
  }

  void clear() {
    _currentUserId = null;
    _currentRoomId = null;
    _currentUserName = null;
  }

  // Generate a GUID format string
  static String generateGuid() {
    final random = Random();
    return '${_generateHex(8)}-${_generateHex(4)}-${_generateHex(4)}-${_generateHex(4)}-${_generateHex(12)}';
  }

  static String _generateHex(int length) {
    final random = Random();
    final chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
