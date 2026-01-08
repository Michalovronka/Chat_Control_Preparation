import 'package:flutter/material.dart';
import 'dart:io';
import '../widgets/glass_message_bubble.dart';

class MessageBubbleBuilder extends StatelessWidget {
  final Map<String, dynamic> message;

  const MessageBubbleBuilder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.containsKey("imagePath") || message["isImage"] == true) {
      final imagePath = message["imagePath"];
      return Align(
        alignment: message["isMe"] ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath != null && imagePath is String
                ? File(imagePath).existsSync()
                    ? Image.file(
                        File(imagePath),
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 200,
                            color: Colors.grey.withOpacity(0.3),
                            child: Icon(Icons.broken_image, color: Colors.white70),
                          );
                        },
                      )
                    : Container(
                        width: 200,
                        height: 200,
                        color: Colors.grey.withOpacity(0.3),
                        child: Center(
                          child: Text(
                            'Obrázek',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      )
                : Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey.withOpacity(0.3),
                    child: Icon(Icons.image, color: Colors.white70),
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
