import 'package:flutter/material.dart';
import 'dart:ui';

class MessageInputSection extends StatelessWidget {
  final TextEditingController messageController;
  final VoidCallback onSendPressed;
  final VoidCallback onAttachPressed;

  const MessageInputSection({
    super.key,
    required this.messageController,
    required this.onSendPressed,
    required this.onAttachPressed,
  });

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
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                            width: 1.5,
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
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
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
                    color: Colors.white.withOpacity(0.06),
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
