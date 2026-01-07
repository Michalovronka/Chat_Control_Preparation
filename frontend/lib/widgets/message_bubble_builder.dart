import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/glass_message_bubble.dart';

class MessageBubbleBuilder extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageBubbleBuilder({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (message.containsKey("imagePath")) {
      return Align(
        alignment: message["isMe"] ? Alignment.centerRight : Alignment.centerLeft,
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
