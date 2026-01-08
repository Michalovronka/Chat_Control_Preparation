import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/glass_message_bubble.dart';
import 'chat_overview_screen.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/message_input_section.dart';
import '../widgets/message_bubble_builder.dart';
import '../widgets/chat_background.dart';
import '../services/signalr_service.dart';
import '../services/app_state.dart';

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
          
          print('Parsed - userId: $userId, userName: $userName, content: "$content"'); // Debug
          
          if (content.isEmpty) {
            print('WARNING: Content is empty!'); // Debug
          }
          
          final isMe = userId == _appState.currentUserId;
          _messages.add({
            "sender": isMe 
                ? "${_appState.currentUserName ?? userName ?? 'You'} (you)" 
                : (userName ?? "User $userId"),
            "content": content,
            "isMe": isMe,
            "isImage": isImage == "true",
          });
        });
        _scrollToBottom();
      });

      // Listen for loaded messages
      _signalRService.onLoadMessages((messages) {
        print('Loaded messages: $messages'); // Debug
        setState(() {
          _messages.clear();
          for (var msg in messages) {
            final msgMap = msg as Map<String, dynamic>;
            // Try both PascalCase and camelCase property names
            final userId = (msgMap['UserId'] ?? msgMap['userId'])?.toString() ?? '';
            final userName = (msgMap['UserName'] ?? msgMap['userName'])?.toString();
            final content = (msgMap['Content'] ?? msgMap['content'])?.toString() ?? '';
            print('Loaded message - userId: $userId, userName: $userName, content: "$content"'); // Debug
            final isMe = userId == _appState.currentUserId;
            _messages.add({
              "sender": isMe 
                  ? "${_appState.currentUserName ?? userName ?? 'You'} (you)" 
                  : (userName ?? "User $userId"),
              "content": content,
              "isMe": isMe,
              "isImage": false,
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
      // TODO: Upload image and send image message
      setState(() {
        _messages.add({
          "sender": "${_appState.currentUserName ?? 'You'} (you)",
          "content": "",
          "isMe": true,
          "imagePath": pickedFile.path,
          "isImage": true,
        });
      });
      _scrollToBottom();
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(chatName: widget.groupName, chatId: widget.roomId ?? "#31161213"),
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
                      return MessageBubbleBuilder(message: message);
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
    );
  }
}
