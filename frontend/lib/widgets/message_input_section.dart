import 'package:flutter/material.dart';
import 'dart:ui';

class MessageInputSection extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed;

  const MessageInputSection({
    Key? key,
    required this.messageController,
    required this.onSendPressed,
    required this.onAttachPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
                      controller: messageController,
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.attach_file, color: Colors.white),
                    onPressed: onAttachPressed,
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
                    onPressed: onSendPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
