import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/glass_message_bubble.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      "sender": "user#5684598765",
      "content":
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed leo dui, sollicitudin a mi vitae, sollicitudin luctus ercu.",
      "isMe": false,
    },
    {
      "sender": "user#09875557876 (you)",
      "content":
          "Etiam vel mauris eget scelerisque condimentum. Aenean id urna eget magna interdum laoreet.",
      "isMe": true,
    },
    {
      "sender": "user#8655755443",
      "content":
          "Donec ut suscipit massa. Cras ultrices tellus in ex aliquam viverra. Vestibulum consequat risus sed.",
      "isMe": false,
    },
  ];

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
        leadingWidth: 60,
        leading: Container(
          margin: EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
              onPressed: () {},
            ),
          ),
        ),
        title: Container(
          margin: EdgeInsets.only(left: 8),
          child: Row(
            children: [
              Text(
                "název chatu",
                style: TextStyle(
                  fontFamily: 'Jura',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(width: 8),
              Text(
                "#898895(id)",
                style: TextStyle(
                  fontFamily: 'Jura',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Stack(
        children: [
          //POZADÍ
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
              padding: EdgeInsets.only(bottom: 100),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return GlassMessageBubble(
                  sender: message["sender"],
                  content: message["content"],
                  isMe: message["isMe"],
                );
              },
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  color: Colors.black.withOpacity(0.2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white,
                              fontSize: 18, // Větší font
                            ),
                            decoration: InputDecoration(
                              hintText: "Napiš zprávu...",
                              hintStyle: TextStyle(
                                fontFamily: 'Jura',
                                color: Colors.white70,
                                fontSize: 18, // Větší font
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.attach_file,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 28,
                          ), // Větší ikona
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
}
