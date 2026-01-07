import 'package:flutter/material.dart';
import '../widgets/user_profile_section.dart';
import '../widgets/chat_tile.dart';
import '../widgets/forum_code_input.dart';
import '../widgets/connect_actions.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _codeController = TextEditingController();
  final String _currentUser = "user#09875557876";

  final List<Map<String, String>> _chats = [
    {"name": "Chat No1", "id": "#31161213"},
    {"name": "Flutter Developers", "id": "#55678912"},
    {"name": "Projekt X", "id": "#98765432"},
    {"name": "Týmová spolupráce", "id": "#45678912"},
    {"name": "Technická podpora", "id": "#12345678"},
    {"name": "Gaming komunita", "id": "#98765431"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Container(color: Colors.black.withOpacity(0.2)),
          // Obsah
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 60),
                UserProfileSection(currentUser: _currentUser),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vaše fóra",
                    style: TextStyle(
                      fontFamily: 'Jura',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      return ChatTile(
                        name: _chats[index]["name"]!,
                        id: _chats[index]["id"]!,
                      );
                    },
                  ),
                ),
                ForumCodeInput(codeController: _codeController),
                ConnectActions(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
