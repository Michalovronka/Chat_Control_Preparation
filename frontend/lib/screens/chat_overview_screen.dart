import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/chat_app_bar.dart';
import '../widgets/participant_tile.dart';
import '../widgets/invite_code_section.dart';
import '../widgets/console_section.dart';

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
  String inviteCode = "16816816";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(chatName: widget.chatName, chatId: "#31161213"),
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
          Column(
            children: [
              // Nadpis "lidé" a seznam účastníků
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "lidé",
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 8),
                    // Seznam účastníků
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          return ParticipantTile(participantName: participants[index]);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Zvací kód
              InviteCodeSection(inviteCode: inviteCode),
              // Konzole pro příkazy
              ConsoleSection(consoleController: _consoleController),
            ],
          ),
        ],
      ),
    );
  }
}
