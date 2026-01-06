import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../widgets/glass_message_bubble.dart';
import 'chat_overview_screen.dart';

class ChatScreen extends StatefulWidget {
  final String groupName;

  ChatScreen({Key? key, this.groupName = "název chatu"}) : super(key: key);

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

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
    backgroundColor: Colors.black.withOpacity(0.2),
    elevation: 0,
    leading: Container(
      margin: EdgeInsets.only(left: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    ),
    title: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatOverviewScreen(chatName: widget.groupName),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.groupName, // Použití názvu chatu
            style: TextStyle(
              fontFamily: 'Jura',
              color: Colors.white.withOpacity(0.8),
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
          Text(
            "#31161213", // ID chatu
            style: TextStyle(
              fontFamily: 'Jura',
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ),


      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.black,
                  Color(0xFF1a0a2a),
                  Color(0xFF133e52),
                  Color(0xFF0a2a1a),
                  Colors.black,
                ],
                stops: [0.0, 0.25, 0.5, 0.75, 1.0],
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.2)),

          Positioned.fill(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: EdgeInsets.only(bottom: 90),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  color: Colors.black.withOpacity(0.3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: "Napiš zprávu...",
                              hintStyle: TextStyle(
                                fontFamily: 'Jura',
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      // Tlačítko pro přidání médií
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.attach_file, color: Colors.white),
                          onPressed:
                              _pickImage, // Volání metody pro výběr obrázku
                        ),
                      ),
                      SizedBox(width: 8),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    if (message.containsKey("imagePath")) {
      return Align(
        alignment: message["isMe"]
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(message["imagePath"]),
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return GlassMessageBubble(
        sender: message["sender"],
        content: message["content"],
        isMe: message["isMe"],
      );
    }
  }
}
