import 'package:flutter/material.dart';
import 'dart:ui';

class ChatOverviewScreen extends StatefulWidget {
  final String chatName;

  ChatOverviewScreen({required this.chatName});

  @override
  _ChatOverviewScreenState createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  final List<String> participants = [
    "User1233",
    "PetrPav_2022",
    "DeVil666",
    "User115156",
    "MaoZTUnk",
    "Iggy",
    "Sajmon55",
    "ORlljdKf",
  ];

  final TextEditingController _consoleController = TextEditingController();

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.chatName, // Název chatu
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white.withOpacity(0.8), // Méně výrazná barva
                fontSize: 20,
                fontWeight: FontWeight.normal, // Normální tučnost
              ),
            ),
            Text(
              "#31161213", // ID chatu
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white70,
                fontSize: 12, // Menší písmo
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // pozadí
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
          Column(
            children: [
              // Nadpis "lidé" a seznam účastníků
              Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seznam účastníků
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          return _buildParticipantTile(participants[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Konzole pro příkazy
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Konzole",
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
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
                            controller: _consoleController,
                            style: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: "Zadejte příkaz...",
                              hintStyle: TextStyle(
                                fontFamily: 'Jura',
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              prefixIcon: Icon(
                                Icons.terminal,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(String participantName) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          participantName,
          style: TextStyle(
            fontFamily: 'Jura',
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tlačítko pro soukromý chat
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
              onPressed: () {
                // TODO: logika pro soukromý chat
              },
            ),
            // Tlačítko pro vyhození člena
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.redAccent),
              onPressed: () {
                // TODO: logika vyhození membera
              },
            ),
          ],
        ),
      ),
    );
  }
}
