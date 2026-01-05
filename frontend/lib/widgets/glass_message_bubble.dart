import 'package:flutter/material.dart';
import 'dart:ui';

class GlassMessageBubble extends StatelessWidget {
  final String sender;
  final String content;
  final bool isMe;

  const GlassMessageBubble({
    super.key,
    required this.sender,
    required this.content,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isMe
                      ? const Color.fromARGB(255, 0, 255, 170)
                      : Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sender,
                    style: TextStyle(
                      fontFamily: 'Jura',
                      fontWeight: FontWeight.bold,
                      color: isMe
                          ? const Color.fromARGB(255, 0, 255, 170)
                          : const Color.fromARGB(255, 255, 255, 255),
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(
                      fontFamily: 'Jura',
                      color: Colors.white,
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
