import 'package:flutter/material.dart';
import 'dart:ui';
import 'chat_screen.dart';
import 'group_chat_invite_screen.dart';

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  _CreateGroupChatScreenState createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        title: Text(
          "Vytvořit nový chat",
          style: TextStyle(
            fontFamily: 'Jura',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Gradientové pozadí
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
          // Lehké ztmavení
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          // Obsah
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nahraný obrázek nebo placeholder
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.group,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Input pro název chatu
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _groupNameController,
                          style: TextStyle(
                            fontFamily: 'Jura',
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          decoration: InputDecoration(
                            hintText: "Název chatu..",
                            hintStyle: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Tlačítko Potvrdit
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupChatInviteScreen(
                            groupName: _groupNameController.text.isNotEmpty
                                ? _groupNameController.text
                                : "Nový Chat",
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    ),
                    child: Text(
                      "Potvrdit",
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
