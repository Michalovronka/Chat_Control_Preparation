import 'package:flutter/material.dart';
import 'dart:ui';

class ForumCodeInput extends StatelessWidget {
  final TextEditingController codeController;

  const ForumCodeInput({super.key, required this.codeController});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: codeController,
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white,
                fontSize: 18,
              ),
              decoration: InputDecoration(
                hintText: "zadejte kód fóra...",
                hintStyle: TextStyle(
                  fontFamily: 'Jura',
                  color: Colors.white70,
                  fontSize: 18,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
