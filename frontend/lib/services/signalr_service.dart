import 'package:signalr_netcore/signalr_client.dart';
import '../config/api_config.dart';
import 'app_state.dart';
import 'user_service.dart';

class SignalRService {
  // Singleton pattern
  static final SignalRService _instance = SignalRService._internal();
  factory SignalRService() => _instance;

  static String get baseUrl => ApiConfig.baseUrl;
  static String get hubPath => '/chathub';
  
  late HubConnection _connection;
  bool _globalInviteListenerSetUp = false;
  Function(Map<String, dynamic>)? _inviteCallback;
  
  HubConnection get connection => _connection;
  
  SignalRService._internal() {
    _connection = HubConnectionBuilder()
        .withUrl('${ApiConfig.getUrl('chathub')}')
        .withAutomaticReconnect()
        .build();
  }
  
  Future<void> start() async {
    try {
      // Set up global invite listener BEFORE starting connection
      // This ensures it's ready as soon as connection is established
      _setupGlobalInviteListener();
      
      // If reconnecting, stop first so we get a clean connection (e.g. after logout).
      // Otherwise we'd skip start() and stay in Reconnecting, causing invoke failures.
      if (_connection.state == HubConnectionState.Reconnecting) {
        print('SignalR was Reconnecting, stopping first for clean start');
        try {
          await _connection.stop();
        } catch (_) {}
      }
      
      // Only start if not already connected
      if (_connection.state == HubConnectionState.Disconnected) {
        await _connection.start();
        print('SignalR Connected');
        print('[INVITE LISTENER] Global invite listener should be active');
      } else {
        print('SignalR already connected or connecting (state: ${_connection.state})');
        // Ensure global listener is set up even if already connected
        _setupGlobalInviteListener();
      }
    } catch (e) {
      print('SignalR Connection Error: $e');
      rethrow;
    }
  }
  
  bool get isConnected => _connection.state == HubConnectionState.Connected;
  
  // Ensure connection is ready before invoking methods
  Future<void> ensureConnected() async {
    // If already connected, verify it's still stable
    if (_connection.state == HubConnectionState.Connected) {
      // Give a small delay to ensure connection is stable
      await Future.delayed(Duration(milliseconds: 100));
      // Double-check state after delay
      if (_connection.state == HubConnectionState.Connected) {
        return;
      }
    }
    
    // If reconnecting, wait for it to complete
    if (_connection.state == HubConnectionState.Reconnecting) {
      print('Connection is reconnecting, waiting...');
      int reconnectingRetries = 0;
      const maxReconnectingRetries = 50; // 5 seconds max wait for reconnection
      while (_connection.state == HubConnectionState.Reconnecting && reconnectingRetries < maxReconnectingRetries) {
        await Future.delayed(Duration(milliseconds: 100));
        reconnectingRetries++;
      }
      
      // If reconnection succeeded, we're done
      if (_connection.state == HubConnectionState.Connected) {
        await Future.delayed(Duration(milliseconds: 100)); // Stability check
        return;
      }
    }
    
    // If disconnected, start the connection
    if (_connection.state == HubConnectionState.Disconnected) {
      await start();
    }
    
    // Wait for connection to be established (with timeout)
    int retries = 0;
    const maxRetries = 50; // 5 seconds max wait
    while (_connection.state != HubConnectionState.Connected && retries < maxRetries) {
      await Future.delayed(Duration(milliseconds: 100));
      retries++;
      
      // If connection is reconnecting, wait for it
      if (_connection.state == HubConnectionState.Reconnecting) {
        print('Connection entered reconnecting state during wait, waiting for reconnect...');
        int reconnectingRetries = 0;
        while (_connection.state == HubConnectionState.Reconnecting && reconnectingRetries < 30) {
          await Future.delayed(Duration(milliseconds: 100));
          reconnectingRetries++;
        }
        // Continue the main loop to check if connected now
        continue;
      }
      
      // If connection failed, try to restart
      if (_connection.state == HubConnectionState.Disconnected && retries > 5) {
        print('Connection lost during wait, attempting to restart...');
        try {
          await start();
        } catch (e) {
          print('Failed to restart connection: $e');
        }
      }
    }
    
    if (_connection.state != HubConnectionState.Connected) {
      throw Exception('Failed to establish SignalR connection. State: ${_connection.state}');
    }
    
    // Additional stability check - wait a bit more to ensure connection is fully ready
    await Future.delayed(Duration(milliseconds: 150));
  }
  
  Future<void> stop() async {
    try {
      if (_connection.state != HubConnectionState.Disconnected) {
        await _connection.stop();
        print('SignalR Disconnected');
      } else {
        print('SignalR already disconnected');
      }
    } catch (e) {
      print('Error stopping SignalR: $e');
      // Don't rethrow - it's okay if stop fails
    }
  }
  
  // Send message - matches SendMessageModel: (Guid RoomId, Guid UserId, string Content, string IsImage, DateTime SentTime)
  Future<void> sendMessage({
    required String userId,
    required String content,
    required String roomId,
    bool isImage = false,
  }) async {
    try {
      await _connection.invoke('SendMessage', args: [
        {
          'RoomId': roomId,
          'UserId': userId,
          'Content': content,
          'IsImage': isImage ? 'true' : 'false',
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
      // Ensure connection is ready before invoking
      await ensureConnected();
      
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

  // Leave room - matches SendLeaveModel: (Guid UserId, Guid RoomId, string? Message, bool PermanentLeave)
  Future<void> sendLeave({
    required String userId,
    required String roomId,
    String? message,
    bool permanentLeave = false, // true for leave button, false for back arrow
  }) async {
    try {
      // Ensure connection is ready before invoking
      await ensureConnected();
      
      await _connection.invoke('SendLeave', args: [
        {
          'UserId': userId,
          'RoomId': roomId,
          'Message': message,
          'PermanentLeave': permanentLeave,
        }
      ]);
    } catch (e) {
      print('Error leaving room: $e');
      rethrow;
    }
  }

  // Kick user - matches SendKickModel: (Guid KickerUserId, Guid KickedUserId, Guid RoomId)
  Future<void> sendKick({
    required String kickerUserId,
    required String kickedUserId,
    required String roomId,
  }) async {
    try {
      // Ensure connection is ready before invoking
      await ensureConnected();
      
      // Double-check connection state right before invoke
      if (_connection.state != HubConnectionState.Connected) {
        print('Connection not ready before sendKick, state: ${_connection.state}');
        await ensureConnected();
      }
      
      print('Sending sendKick, connection state: ${_connection.state}');
      
      await _connection.invoke('SendKick', args: [
        {
          'KickerUserId': kickerUserId,
          'KickedUserId': kickedUserId,
          'RoomId': roomId,
        }
      ]);
      
      print('sendKick completed successfully');
    } catch (e) {
      print('Error kicking user: $e');
      print('Connection state during error: ${_connection.state}');
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
    int retryCount = 0;
    const maxRetries = 5; // Increased retries
    
    while (retryCount < maxRetries) {
      try {
        // Ensure connection is ready before invoking
        await ensureConnected();
        
        // Double-check connection state right before invoke
        if (_connection.state != HubConnectionState.Connected) {
          print('Connection not ready before sendShowMessages, state: ${_connection.state}');
          await ensureConnected();
        }
        
        // Additional stability check - wait longer and verify connection is truly stable
        await Future.delayed(Duration(milliseconds: 500)); // Increased delay
        if (_connection.state != HubConnectionState.Connected) {
          print('Connection became unstable during wait, state: ${_connection.state}');
          // Wait for reconnection if it's reconnecting
          if (_connection.state == HubConnectionState.Reconnecting) {
            print('Connection is reconnecting, waiting...');
            int reconnectWait = 0;
            while (_connection.state == HubConnectionState.Reconnecting && reconnectWait < 30) {
              await Future.delayed(Duration(milliseconds: 200));
              reconnectWait++;
            }
            if (_connection.state != HubConnectionState.Connected) {
              print('Reconnection failed or timed out, attempting to reconnect...');
              await start();
              await Future.delayed(Duration(milliseconds: 500));
            }
          } else {
            await ensureConnected();
          }
        }
        
        // Final check before invoke
        if (_connection.state != HubConnectionState.Connected) {
          throw Exception('Connection not stable: ${_connection.state}');
        }
        
        print('Sending sendShowMessages (attempt ${retryCount + 1}), connection state: ${_connection.state}');
        
        // SendShowMessagesModel expects IReadOnlyList<MessageDto> Message, but we send empty list to request
        await _connection.invoke('SendShowMessages', args: [
          {
            'Message': [],
          }
        ]);
        
        print('sendShowMessages completed successfully');
        return; // Success, exit retry loop
      } catch (e) {
        retryCount++;
        print('Error requesting messages (attempt $retryCount/$maxRetries): $e');
        print('Connection state during error: ${_connection.state}');
        
        if (retryCount >= maxRetries) {
          print('Max retries reached for sendShowMessages');
          rethrow;
        }
        
        // If connection is reconnecting or disconnected, wait longer and try again
        if (_connection.state == HubConnectionState.Reconnecting || 
            _connection.state == HubConnectionState.Disconnected) {
          print('Connection unstable, waiting before retry...');
          await Future.delayed(Duration(milliseconds: 1000)); // Wait longer
          
          // Try to reconnect if disconnected
          if (_connection.state == HubConnectionState.Disconnected) {
            try {
              print('Attempting to reconnect...');
              await start();
              await Future.delayed(Duration(milliseconds: 500));
            } catch (reconnectError) {
              print('Failed to reconnect: $reconnectError');
            }
          } else if (_connection.state == HubConnectionState.Reconnecting) {
            // Wait for reconnection to complete
            print('Waiting for reconnection to complete...');
            int waitCount = 0;
            while (_connection.state == HubConnectionState.Reconnecting && waitCount < 20) {
              await Future.delayed(Duration(milliseconds: 200));
              waitCount++;
            }
          }
        } else {
          // For other errors, wait a bit before retrying
          await Future.delayed(Duration(milliseconds: 500));
        }
      }
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

  // Listen to user kicked event
  void onUserKicked(Function(Map<String, dynamic>) callback) {
    _connection.on('UserKicked', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }

  // Send Who - get users in current room
  Future<void> sendWho() async {
    try {
      await _connection.invoke('SendWho', args: [{}]);
    } catch (e) {
      print('Error requesting who: $e');
      rethrow;
    }
  }

  // Listen to receive who
  void onReceiveWho(Function(Map<String, dynamic>) callback) {
    _connection.on('ReceiveWho', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }

  // Send Query - invite user
  Future<void> sendQuery({
    required String senderUserId,
    required String receiverUserId,
    required String roomId,
  }) async {
    try {
      print('[INVITE SENT] Sender: $senderUserId, Receiver: $receiverUserId, Room: $roomId');
      await _connection.invoke('SendQuery', args: [
        {
          'SenderUserId': senderUserId,
          'ReceiverUserId': receiverUserId,
          'RoomId': roomId,
        }
      ]);
      print('[INVITE SENT] Successfully sent invite');
    } catch (e) {
      print('[INVITE ERROR] Error sending query: $e');
      rethrow;
    }
  }

  // Listen to receive query
  // Set up global invite listener that processes invites automatically
  void _setupGlobalInviteListener() {
    if (_globalInviteListenerSetUp) {
      print('[INVITE LISTENER] Global invite listener already set up');
      return;
    }
    
    print('[INVITE LISTENER] Setting up global ReceiveQuery listener');
    _connection.on('ReceiveQuery', (arguments) {
      print('[INVITE RECEIVED] Raw SignalR arguments received: $arguments');
      print('[INVITE RECEIVED] Arguments type: ${arguments.runtimeType}, length: ${arguments?.length ?? 0}');
      if (arguments != null && arguments.isNotEmpty) {
        try {
          final data = arguments[0] as Map<String, dynamic>;
          print('[INVITE RECEIVED] Parsed data - Sender: ${data['SenderUserId'] ?? data['senderUserId']}, Receiver: ${data['ReceiverUserId'] ?? data['receiverUserId']}, Room: ${data['RoomId'] ?? data['roomId']}');
          print('[INVITE RECEIVED] Full data map: $data');
          
          // Process invite automatically using AppState
          final appState = AppState();
          final senderUserId = (data['SenderUserId'] ?? data['senderUserId'])?.toString();
          final receiverUserId = (data['ReceiverUserId'] ?? data['receiverUserId'])?.toString();
          final roomId = (data['RoomId'] ?? data['roomId'])?.toString();
          
          print('[INVITE RECEIVED] Processing - Sender: $senderUserId, Receiver: $receiverUserId, Room: $roomId, CurrentUser: ${appState.currentUserId}');
          
          // Normalize IDs for comparison
          final normalizedReceiverId = receiverUserId?.toString().trim().toLowerCase() ?? '';
          final normalizedCurrentUserId = appState.currentUserId?.toString().trim().toLowerCase() ?? '';
          
          print('[INVITE RECEIVED] Normalized comparison - receiver: "$normalizedReceiverId", current: "$normalizedCurrentUserId", match: ${normalizedReceiverId == normalizedCurrentUserId}');
          
          // Check if this invite is for the current user
          if (senderUserId != null && roomId != null && normalizedReceiverId == normalizedCurrentUserId && normalizedReceiverId.isNotEmpty) {
            print('[INVITE RECEIVED] Invite is for current user, fetching sender info...');
            // Get sender's username and store the invite
            UserService.getUser(senderUserId).then((user) {
              if (user != null) {
                final senderUserName = (user['UserName'] ?? user['userName'])?.toString() ?? 'Unknown User';
                print('[INVITE RECEIVED] Adding invite to AppState - Sender: $senderUserName ($senderUserId), Room: $roomId');
                appState.addInvite(senderUserId, senderUserName, roomId);
                print('[INVITE RECEIVED] Invite successfully added to AppState');
                
                // Call custom callback if set (for UI updates)
                if (_inviteCallback != null) {
                  try {
                    _inviteCallback!(data);
                  } catch (e) {
                    print('[INVITE ERROR] Error in invite callback: $e');
                  }
                }
              } else {
                print('[INVITE ERROR] Could not fetch sender user info');
              }
            }).catchError((e) {
              print('[INVITE ERROR] Error fetching sender user: $e');
            });
          } else {
            print('[INVITE ERROR] Invite validation failed - Sender: $senderUserId, Room: $roomId, Receiver matches: ${normalizedReceiverId == normalizedCurrentUserId}');
          }
        } catch (e) {
          print('[INVITE ERROR] Error parsing ReceiveQuery arguments: $e');
          print('[INVITE ERROR] Arguments[0] type: ${arguments[0].runtimeType}, value: ${arguments[0]}');
        }
      } else {
        print('[INVITE ERROR] Received query with empty or null arguments');
      }
    });
    _globalInviteListenerSetUp = true;
    print('[INVITE LISTENER] Global ReceiveQuery listener set up successfully');
  }

  // Set a callback for when invites are received (for UI updates)
  void setInviteCallback(Function(Map<String, dynamic>)? callback) {
    _inviteCallback = callback;
  }

  // Legacy method for backward compatibility - now uses global listener
  void onReceiveQuery(Function(Map<String, dynamic>) callback) {
    // Set up global listener if not already set up
    _setupGlobalInviteListener();
    
    // Set the callback for UI updates
    setInviteCallback(callback);
  }

  // Register connection - sets ConnectionId for the user
  Future<void> registerConnection(String userId) async {
    try {
      // Ensure connection is ready before invoking
      await ensureConnected();
      
      print('[CONNECTION REGISTER] Registering connection for user: $userId');
      print('[CONNECTION REGISTER] Connection state before invoke: ${_connection.state}');
      
      await _connection.invoke('RegisterConnection', args: [
        {
          'UserId': userId,
        }
      ]);
      
      // Wait a bit after registration to ensure connection is stable
      await Future.delayed(Duration(milliseconds: 200));
      
      print('[CONNECTION REGISTER] Successfully registered connection');
      print('[CONNECTION REGISTER] Connection state after registration: ${_connection.state}');
    } catch (e) {
      print('[CONNECTION ERROR] Error registering connection: $e');
      print('[CONNECTION ERROR] Connection state: ${_connection.state}');
      rethrow;
    }
  }

  // Block/Unblock user
  Future<void> sendBlock({
    required String userId,
    required String blockedUserId,
    required bool isBlock,
  }) async {
    try {
      // Ensure connection is ready before invoking
      await ensureConnected();
      
      await _connection.invoke('SendBlock', args: [
        {
          'UserId': userId,
          'BlockedUserId': blockedUserId,
          'IsBlock': isBlock,
        }
      ]);
    } catch (e) {
      print('Error blocking/unblocking user: $e');
      rethrow;
    }
  }

  // Listen to block updates
  void onBlockUpdated(Function(Map<String, dynamic>) callback) {
    _connection.on('BlockUpdated', (arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        callback(arguments[0] as Map<String, dynamic>);
      }
    });
  }
}
