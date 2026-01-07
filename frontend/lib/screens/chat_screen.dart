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

class ChatScreen extends StatefulWidget {
  final String groupName;

  const ChatScreen({super.key, this.groupName = "název chatu"});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "user#5684598765",
      "content": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
      "isMe": false,
    },
    {
      "sender": "user#09875557876 (you)",
      "content": "Etiam vel mauris eget scelerisque condimentum.",
      "isMe": true,
    },
  ];

  final ScrollController _scrollController = ScrollController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _messages.add({
          "sender": "user#09875557876 (you)",
          "content": "",
          "isMe": true,
          "imagePath": pickedFile.path,
        });
      });
      _scrollToBottom();
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    setState(() {
      _messages.add({
        "sender": "user#09875557876 (you)",
        "content": _messageController.text,
        "isMe": true,
      });
    });
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(chatName: widget.groupName, chatId: "#31161213"),
      body: Stack(
        children: [
          ChatBackground(),
          Positioned.fill(
            child: ListView.builder(
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
