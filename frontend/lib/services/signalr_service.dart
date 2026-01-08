import 'package:signalr_netcore/signalr_client.dart';

class SignalRService {
  // Use HTTP for development (easier for mobile/web)
  static const String baseUrl = 'http://localhost:5202';
  static const String hubPath = '/chathub';
  
  late HubConnection _connection;
  
  HubConnection get connection => _connection;
  
  SignalRService() {
    _connection = HubConnectionBuilder()
        .withUrl('$baseUrl$hubPath')
        .withAutomaticReconnect()
        .build();
  }
  
  Future<void> start() async {
    try {
      await _connection.start();
      print('SignalR Connected');
    } catch (e) {
      print('SignalR Connection Error: $e');
      rethrow;
    }
  }
  
  Future<void> stop() async {
    await _connection.stop();
    print('SignalR Disconnected');
  }
  
  // Send message - matches SendMessageModel: (Guid RoomId, Guid UserId, string Content, DateTime SentTime)
  Future<void> sendMessage({
    required String userId,
    required String content,
    required String roomId,
  }) async {
    try {
      await _connection.invoke('SendMessage', args: [
        {
          'RoomId': roomId,
          'UserId': userId,
          'Content': content,
          'SentTime': DateTime.now().toIso8601String(),
        }
      ]);
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
  
  // Join room - matches SendJoinModel: (Guid UserId, Guid RoomId, string? Message)
  Future<void> sendJoin({
    required String userId,
    required String roomId,
    String? message,
  }) async {
    try {
      await _connection.invoke('SendJoin', args: [
        {
          'UserId': userId,
          'RoomId': roomId,
          'Message': message,
        }
      ]);
    } catch (e) {
      print('Error joining room: $e');
      rethrow;
    }
  }

  // Leave room - matches SendLeaveModel: (Guid UserId, Guid RoomId, string? Message)
  Future<void> sendLeave({
    required String userId,
    required String roomId,
    String? message,
  }) async {
    try {
      await _connection.invoke('SendLeave', args: [
        {
          'UserId': userId,
          'RoomId': roomId,
          'Message': message,
        }
      ]);
    } catch (e) {
      print('Error leaving room: $e');
      rethrow;
    }
  }
  
  // Listen to messages
  void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    _connection.on('ReceiveMessage', (arguments) {
      print('SignalR ReceiveMessage arguments: $arguments'); // Debug
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final message = arguments[0];
          if (message is Map<String, dynamic>) {
            print('Message is Map: $message'); // Debug
            callback(message);
          } else {
            print('Message is not a Map, type: ${message.runtimeType}'); // Debug
            // Try to convert if it's a different type
            callback({'Content': message.toString(), 'UserId': '', 'IsImage': 'false', 'RoomId': ''});
          }
        } catch (e) {
          print('Error parsing message: $e'); // Debug
        }
      }
    });
  }
  
  // Listen to errors
  void onError(Function(String) callback) {
    _connection.on('Error', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as String);
      }
    });
  }
  
  // Listen to user joined
  void onUserJoined(Function(Map<String, dynamic>) callback) {
    _connection.on('UserJoined', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }
  
  // Listen to user left
  void onUserLeft(Function(Map<String, dynamic>) callback) {
    _connection.on('UserLeft', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }
  
  // Listen to load messages
  void onLoadMessages(Function(List<dynamic>) callback) {
    _connection.on('LoadMessages', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as List<dynamic>);
      }
    });
  }

  // Request to show messages for current room
  Future<void> sendShowMessages() async {
    try {
      // SendShowMessagesModel expects IReadOnlyList<MessageDto> Message, but we send empty list to request
      await _connection.invoke('SendShowMessages', args: [
        {
          'Message': [],
        }
      ]);
    } catch (e) {
      print('Error requesting messages: $e');
      rethrow;
    }
  }

  // Listen to receive show messages
  void onReceiveShowMessages(Function(Map<String, dynamic>) callback) {
    _connection.on('ReceiveShowMessages', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }

  // Listen to receive join
  void onReceiveJoin(Function(Map<String, dynamic>) callback) {
    _connection.on('ReceiveJoin', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }

  // Listen to receive leave
  void onReceiveLeave(Function(Map<String, dynamic>) callback) {
    _connection.on('ReceiveLeave', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }
}
