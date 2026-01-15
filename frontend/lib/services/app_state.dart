import 'dart:math';

/// Simple state management for current user and room
class AppState {
  static final AppState _instance = AppState._internal();
  factory AppState() => _instance;
  AppState._internal();

  String? _currentUserId;
  String? _currentRoomId;
  String? _currentUserName;
  final List<Map<String, dynamic>> _receivedInvites = []; // List of invites: {senderUserId, senderUserName, roomId}
  List<String> _blockedUsers = []; // List of blocked user IDs

  String? get currentUserId => _currentUserId;
  String? get currentRoomId => _currentRoomId;
  String? get currentUserName => _currentUserName;
  List<Map<String, dynamic>> get receivedInvites => List.unmodifiable(_receivedInvites);
  List<String> get blockedUsers => List.unmodifiable(_blockedUsers);

  bool isUserBlocked(String userId) {
    return _blockedUsers.contains(userId);
  }

  void setBlockedUsers(List<String> userIds) {
    _blockedUsers = List.from(userIds);
  }

  void addBlockedUser(String userId) {
    if (!_blockedUsers.contains(userId)) {
      _blockedUsers.add(userId);
    }
  }

  void removeBlockedUser(String userId) {
    _blockedUsers.remove(userId);
  }

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

  void addInvite(String senderUserId, String senderUserName, String roomId) {
    // Check if invite already exists for this sender and room
    if (!_receivedInvites.any((invite) => 
        invite['senderUserId'] == senderUserId && invite['roomId'] == roomId)) {
      _receivedInvites.add({
        'senderUserId': senderUserId,
        'senderUserName': senderUserName,
        'roomId': roomId,
      });
    }
  }

  void removeInvite(String senderUserId, String roomId) {
    _receivedInvites.removeWhere((invite) => 
        invite['senderUserId'] == senderUserId && invite['roomId'] == roomId);
  }

  void clearInvites() {
    _receivedInvites.clear();
  }

  void clear() {
    _currentUserId = null;
    _currentRoomId = null;
    _currentUserName = null;
    _receivedInvites.clear();
    _blockedUsers.clear();
  }

  // Generate a GUID format string
  static String generateGuid() {
    return '${_generateHex(8)}-${_generateHex(4)}-${_generateHex(4)}-${_generateHex(4)}-${_generateHex(12)}';
  }

  static String _generateHex(int length) {
    final random = Random();
    final chars = '0123456789abcdef';
    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
