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
        print('Received message: $message'); // Debug
        setState(() {
          // Try both PascalCase and camelCase property names
          final userId = (message['UserId'] ?? message['userId'])?.toString() ?? '';
          final userName = (message['UserName'] ?? message['userName'])?.toString();
          final content = (message['Content'] ?? message['content'])?.toString() ?? '';
          final isImage = (message['IsImage'] ?? message['isImage'])?.toString() ?? 'false';
          
          print('Parsed - userId: $userId, userName: $userName, content: "$content", isImage: $isImage'); // Debug
          
          // Check if message is an image
          final bool isImageMessage = isImage == "true" || isImage == "True";
          final String? imagePath = isImageMessage ? content : null;
          
          final isMe = userId == _appState.currentUserId;
          final finalImagePath = imagePath != null ? ImageService.getImageUrl(imagePath) : null;
          print('Adding message - isImage: $isImageMessage, imagePath: $finalImagePath, content: $content');
          _messages.add({
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
            
            // Check if message is an image
            final bool isImageMessage = isImage == "true" || isImage == "True";
            final String? imagePath = isImageMessage ? content : null;
            
            final isMe = userId == _appState.currentUserId;
            _messages.add({
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

      // Listen for user kicked event
      _signalRService.onUserKicked((data) {
        print('User kicked event received: $data');
        final roomId = (data['RoomId'] ?? data['roomId'])?.toString().replaceAll('#', '').trim();
        final currentRoomId = _appState.currentRoomId?.replaceAll('#', '').trim();
        
        // Only handle if kicked from the current room
        if (roomId != null && currentRoomId != null && roomId == currentRoomId) {
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

      // Connect to SignalR
      await _signalRService.start();
      
      // Ensure user and room are set
      if (_appState.currentUserId == null) {
        final userId = AppState.generateGuid();
        _appState.setUser(userId, 'User');
      }

      if (widget.roomId != null && _appState.currentUserId != null) {
        _appState.setRoom(widget.roomId!);
        // Join the room
        await _signalRService.sendJoin(
          userId: _appState.currentUserId!,
          roomId: widget.roomId!,
        );
        // Load existing messages
        await _signalRService.sendShowMessages();
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
    _signalRService.stop();
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
