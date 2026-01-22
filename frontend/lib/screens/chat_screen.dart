import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_input_section.dart';
import '../widgets/message_bubble_builder.dart';
import '../widgets/chat_background.dart';
import '../services/signalr_service.dart';
import '../services/app_state.dart';
import '../services/image_service.dart';
import 'connect_screen.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;
  final String? roomId;

  const ChatScreen({super.key, this.groupName = "název chatu", this.roomId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final SignalRService _signalRService = SignalRService();
  final AppState _appState = AppState();
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeSignalR();
  }

  Future<void> _initializeSignalR() async {
    try {
      // Set up message listeners before connecting
      _signalRService.onReceiveMessage((message) {
        if (!mounted) return;
        print('Received message: $message'); // Debug
        setState(() {
          // Try both PascalCase and camelCase property names
          final userId = (message['UserId'] ?? message['userId'])?.toString() ?? '';
          final userName = (message['UserName'] ?? message['userName'])?.toString();
          final content = (message['Content'] ?? message['content'])?.toString() ?? '';
          final isImage = (message['IsImage'] ?? message['isImage'])?.toString() ?? 'false';
          
          print('Parsed - userId: $userId, userName: $userName, content: "$content", isImage: $isImage'); // Debug
          
          // Check if sender is blocked - don't show messages from blocked users
          if (_appState.isUserBlocked(userId)) {
            print('Message from blocked user $userId - ignoring');
            return;
          }
          
          // Check if message is an image
          final bool isImageMessage = isImage == "true" || isImage == "True";
          final String? imagePath = isImageMessage ? content : null;
          
          final isMe = userId == _appState.currentUserId;
          final finalImagePath = imagePath != null ? ImageService.getImageUrl(imagePath) : null;
          print('Adding message - isImage: $isImageMessage, imagePath: $finalImagePath, content: $content');
          _messages.add({
            "userId": userId, // Store userId for filtering blocked users
            "sender": isMe 
                ? "${_appState.currentUserName ?? userName ?? 'You'} (you)" 
                : (userName ?? "User $userId"),
            "content": isImageMessage ? "" : content,
            "isMe": isMe,
            "isImage": isImageMessage,
            if (finalImagePath != null) "imagePath": finalImagePath,
          });
        });
        _scrollToBottom();
      });

      // Listen for loaded messages
      _signalRService.onLoadMessages((messages) {
        if (!mounted) return;
        print('Loaded messages: $messages'); // Debug
        setState(() {
          _messages.clear();
          
          // Convert to list and sort by SentTime to ensure proper order
          final messagesList = messages.map((msg) => msg as Map<String, dynamic>).toList();
          
          // Sort by SentTime (ascending - oldest first, newest last)
          messagesList.sort((a, b) {
            final timeA = (a['SentTime'] ?? a['sentTime'])?.toString() ?? '';
            final timeB = (b['SentTime'] ?? b['sentTime'])?.toString() ?? '';
            if (timeA.isEmpty || timeB.isEmpty) return 0;
            try {
              final dateA = DateTime.parse(timeA);
              final dateB = DateTime.parse(timeB);
              return dateA.compareTo(dateB);
            } catch (e) {
              return 0;
            }
          });
          
          for (var msgMap in messagesList) {
            // Try both PascalCase and camelCase property names
            final userId = (msgMap['UserId'] ?? msgMap['userId'])?.toString() ?? '';
            final userName = (msgMap['UserName'] ?? msgMap['userName'])?.toString();
            final content = (msgMap['Content'] ?? msgMap['content'])?.toString() ?? '';
            final isImage = (msgMap['IsImage'] ?? msgMap['isImage'])?.toString() ?? 'false';
            print('Loaded message - userId: $userId, userName: $userName, content: "$content", isImage: $isImage'); // Debug
            
            // Check if sender is blocked - don't show messages from blocked users
            if (_appState.isUserBlocked(userId)) {
              print('Message from blocked user $userId - ignoring');
              continue;
            }
            
            // Check if message is an image
            final bool isImageMessage = isImage == "true" || isImage == "True";
            final String? imagePath = isImageMessage ? content : null;
            
            final isMe = userId == _appState.currentUserId;
            _messages.add({
              "userId": userId, // Store userId for filtering blocked users
              "sender": isMe 
                  ? "${_appState.currentUserName ?? userName ?? 'You'} (you)" 
                  : (userName ?? "User $userId"),
              "content": isImageMessage ? "" : content,
              "isMe": isMe,
              "isImage": isImageMessage,
              if (imagePath != null) "imagePath": ImageService.getImageUrl(imagePath),
            });
          }
        });
        _scrollToBottom();
      });

      _signalRService.onError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      });

      // Listen for block updates
      _signalRService.onBlockUpdated((data) async {
        if (!mounted) return;
        print('[BLOCK UPDATE] Block status changed: $data');
        final blockedUserId = (data['BlockedUserId'] ?? data['blockedUserId'])?.toString();
        final isBlocked = (data['IsBlocked'] ?? data['isBlocked']) == true;
        
        if (blockedUserId != null && mounted) {
          // Update AppState
          if (isBlocked) {
            _appState.addBlockedUser(blockedUserId);
          } else {
            _appState.removeBlockedUser(blockedUserId);
          }
          
          if (mounted) {
            setState(() {
              // Filter out messages from blocked user if blocking
              if (isBlocked) {
                // Remove messages from the blocked user
                _messages.removeWhere((msg) => msg['userId']?.toString() == blockedUserId);
                print('[BLOCK UPDATE] Removed messages from blocked user: $blockedUserId');
              }
            });
            
            // If unblocking, reload messages to show previously hidden ones
            if (!isBlocked) {
              print('[BLOCK UPDATE] User unblocked: $blockedUserId - reloading messages');
              try {
                // Reload messages from the server to show previously hidden messages
                await _signalRService.sendShowMessages();
              } catch (e) {
                print('[BLOCK UPDATE] Error reloading messages after unblock: $e');
              }
            }
          }
        }
      });

      // Listen for user kicked event
      _signalRService.onUserKicked((data) {
        if (!mounted) return;
        print('User kicked event received: $data');
        final roomId = (data['RoomId'] ?? data['roomId'])?.toString().replaceAll('#', '').trim();
        final currentRoomId = _appState.currentRoomId?.replaceAll('#', '').trim();
        
        // Only handle if kicked from the current room
        if (roomId != null && currentRoomId != null && roomId == currentRoomId && mounted) {
          // Clear room from app state
          _appState.clearRoom();
          
          // Stop SignalR connection
          _signalRService.stop();
          
          // Show warning message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Byli jste vyhozeni z této místnosti'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
            
            // Navigate back to home screen
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => ConnectScreen(),
              ),
              (route) => false,
            );
          }
        }
      });

      // Connect to SignalR - ensure connection is active
      if (!_signalRService.isConnected) {
        await _signalRService.start();
      } else {
        print('SignalR already connected, reusing existing connection');
      }
      
      // Ensure user and room are set
      if (_appState.currentUserId == null) {
        final userId = AppState.generateGuid();
        _appState.setUser(userId, 'User');
      }

      if (widget.roomId != null && _appState.currentUserId != null) {
        // Set up ReceiveJoin listener BEFORE joining to ensure we catch the confirmation
        bool joinConfirmed = false;
        _signalRService.onReceiveJoin((data) {
          final receivedRoomId = (data['RoomId'] ?? data['roomId'])?.toString();
          final receivedUserId = (data['UserId'] ?? data['userId'])?.toString();
          print('[JOIN CONFIRMATION] Received ReceiveJoin - RoomId: $receivedRoomId, UserId: $receivedUserId, CurrentUser: ${_appState.currentUserId}');
          
          // Check if this is for our user and our room
          final normalizedReceivedRoomId = receivedRoomId?.replaceAll('#', '').trim().toLowerCase() ?? '';
          final normalizedCurrentRoomId = widget.roomId!.replaceAll('#', '').trim().toLowerCase();
          final normalizedReceivedUserId = receivedUserId?.replaceAll('#', '').trim().toLowerCase() ?? '';
          final normalizedCurrentUserId = _appState.currentUserId!.replaceAll('#', '').trim().toLowerCase();
          
          if (normalizedReceivedRoomId == normalizedCurrentRoomId && 
              normalizedReceivedUserId == normalizedCurrentUserId) {
            print('[JOIN CONFIRMATION] Join confirmed for room: $receivedRoomId, user: $receivedUserId');
            joinConfirmed = true;
          } else {
            print('[JOIN CONFIRMATION] Join event received but not for this user/room - Room: $normalizedReceivedRoomId vs $normalizedCurrentRoomId, User: $normalizedReceivedUserId vs $normalizedCurrentUserId');
          }
        });
        
        // Register connection first to ensure ConnectionId is set
        await _signalRService.registerConnection(_appState.currentUserId!);
        
        // Wait longer after registration to ensure connection is fully stable
        await Future.delayed(Duration(milliseconds: 500));
        
        // Verify connection is still active before proceeding
        if (!_signalRService.isConnected) {
          print('Connection lost after registration, attempting to reconnect...');
          await _signalRService.start();
          await _signalRService.registerConnection(_appState.currentUserId!);
          await Future.delayed(Duration(milliseconds: 500));
        }
        
        // Always join the room to ensure backend has CurrentRoomId set
        print('[JOIN] Sending join request for room: ${widget.roomId}');
        await _signalRService.sendJoin(
          userId: _appState.currentUserId!,
          roomId: widget.roomId!,
        );
        
        // Wait for join confirmation with timeout
        print('[JOIN] Waiting for join confirmation...');
        int joinWaitRetries = 0;
        const maxJoinWaitRetries = 50; // 5 seconds max wait
        while (!joinConfirmed && joinWaitRetries < maxJoinWaitRetries) {
          await Future.delayed(Duration(milliseconds: 100));
          joinWaitRetries++;
        }
        
        if (joinConfirmed) {
          print('[JOIN] Join confirmed successfully after ${joinWaitRetries * 100}ms');
        } else {
          print('[JOIN] Join confirmation timeout after ${joinWaitRetries * 100}ms, proceeding anyway...');
        }
        
        // Wait longer for backend to fully process the join and connection to stabilize
        print('[JOIN] Waiting for connection to stabilize after join...');
        await Future.delayed(Duration(milliseconds: 1500));
        
        // Verify connection is still stable after join - with multiple checks
        int stabilityChecks = 0;
        const maxStabilityChecks = 10;
        while (!_signalRService.isConnected && stabilityChecks < maxStabilityChecks) {
          print('[JOIN] Connection not stable, checking... (attempt ${stabilityChecks + 1})');
          await Future.delayed(Duration(milliseconds: 200));
          stabilityChecks++;
        }
        
        if (!_signalRService.isConnected) {
          print('[JOIN] Connection lost after join, attempting to reconnect...');
          try {
            await _signalRService.start();
            await Future.delayed(Duration(milliseconds: 500));
            await _signalRService.registerConnection(_appState.currentUserId!);
            await Future.delayed(Duration(milliseconds: 500));
            await _signalRService.sendJoin(
              userId: _appState.currentUserId!,
              roomId: widget.roomId!,
            );
            await Future.delayed(Duration(milliseconds: 1500));
          } catch (e) {
            print('[JOIN] Error during reconnection: $e');
          }
        }
        
        // Additional stability wait before loading messages
        print('[JOIN] Final stability check before loading messages...');
        await Future.delayed(Duration(milliseconds: 500));
        
        // Ensure connection is truly stable before proceeding
        if (!_signalRService.isConnected) {
          print('[JOIN] Connection still not stable, waiting for reconnection...');
          int waitRetries = 0;
          while (!_signalRService.isConnected && waitRetries < 20) {
            await Future.delayed(Duration(milliseconds: 200));
            waitRetries++;
          }
        }
        
        // Set room in app state after successful join
        _appState.setRoom(widget.roomId!);
        
        // Load existing messages after joining - with retry logic built in
        print('[MESSAGES] Attempting to load messages...');
        print('[MESSAGES] Connection state before loading: ${_signalRService.isConnected}');
        
        // Wait a bit more to ensure connection is truly ready
        await Future.delayed(Duration(milliseconds: 300));
        
        try {
          await _signalRService.sendShowMessages();
          print('[MESSAGES] Messages loaded successfully');
        } catch (e) {
          print('[MESSAGES] Failed to load messages initially: $e');
          // Wait longer before retry to allow connection to stabilize
          await Future.delayed(Duration(milliseconds: 2000));
          try {
            print('[MESSAGES] Retrying message load...');
            // Ensure connection is still good before retry
            if (!_signalRService.isConnected) {
              print('[MESSAGES] Connection lost, reconnecting before retry...');
              await _signalRService.start();
              await Future.delayed(Duration(milliseconds: 500));
              await _signalRService.registerConnection(_appState.currentUserId!);
              await Future.delayed(Duration(milliseconds: 500));
            }
            await _signalRService.sendShowMessages();
            print('[MESSAGES] Messages loaded successfully on retry');
          } catch (retryError) {
            print('[MESSAGES] Failed to load messages on retry: $retryError');
            // Don't fail the entire initialization if messages fail to load
            // They can be loaded later or the user can refresh
          }
        }
      }

      setState(() {
        _isConnected = true;
        _isLoading = false;
      });
    } catch (e) {
      print('Failed to initialize SignalR: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to connect: $e')),
        );
      }
    }
  }

  Future<void> _handleBackNavigation() async {
    final roomId = _appState.currentRoomId;
    
    // Just leave the room and navigate back (temporary leave - user stays in lists)
    if (_isConnected && _appState.currentUserId != null && roomId != null) {
      try {
        await _signalRService.sendLeave(
          userId: _appState.currentUserId!,
          roomId: roomId,
          permanentLeave: false, // Back arrow = temporary leave
        );
        print('Left room via SignalR (temporary)');
      } catch (e) {
        print('Error leaving room: $e');
      }
    }
    
    // Navigate back and refresh rooms list
    if (mounted) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        // Refresh rooms when returning to previous screen
        // This will be handled by didChangeDependencies in ConnectScreen
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectScreen(),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    // Don't stop SignalR connection here - it's a singleton shared across screens
    // The connection should persist across navigations
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final userId = _appState.currentUserId;
      final roomId = _appState.currentRoomId;

      if (userId == null || roomId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User or room not set')),
        );
        return;
      }

      try {
        // Show loading indicator
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nahrávání obrázku...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        // Upload image to server
        final imagePath = await ImageService.uploadImage(pickedFile);

        if (imagePath == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nepodařilo se nahrát obrázek')),
            );
          }
          return;
        }

        // Send message with image path
        // Don't add to local messages - let SignalR handle it via onReceiveMessage
        await _signalRService.sendMessage(
          userId: userId,
          content: imagePath,
          roomId: roomId,
          isImage: true,
        );
      } catch (e) {
        print('Error sending image: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chyba při odesílání obrázku: $e')),
          );
        }
      }
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || !_isConnected) return;
    
    final content = _messageController.text;
    final userId = _appState.currentUserId;
    final roomId = _appState.currentRoomId;

    if (userId == null || roomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User or room not set')),
      );
      return;
    }

    try {
      await _signalRService.sendMessage(
        userId: userId,
        content: content,
        roomId: roomId,
      );
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.minScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _handleBackNavigation();
        return false; // Prevent default navigation, we handle it ourselves
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: ChatAppBar(
          chatName: widget.groupName, 
          chatId: widget.roomId != null 
              ? '#${widget.roomId!.length >= 8 ? widget.roomId!.substring(0, 8) : widget.roomId!}' 
              : "#31161213",
          fullRoomId: widget.roomId, // Pass full room ID for API calls
          signalRService: _signalRService,
          onBackPressed: _handleBackNavigation, // Handle back button in AppBar
        ),
        body: Stack(
        children: [
          ChatBackground(),
          Positioned.fill(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    controller: _scrollController,
                    padding: EdgeInsets.only(bottom: 90),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[_messages.length - 1 - index];
                      // Use a unique key based on message content and imagePath to force rebuild
                      final messageKey = '${message["content"]}_${message["imagePath"]}_$index';
                      return MessageBubbleBuilder(
                        key: ValueKey(messageKey),
                        message: message,
                      );
                    },
                  ),
          ),
          MessageInputSection(
            messageController: _messageController,
            onSendPressed: _sendMessage,
            onAttachPressed: _pickImage,
          ),
        ],
      ),
      ),
    );
  }
}
