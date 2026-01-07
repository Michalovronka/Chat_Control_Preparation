import 'package:flutter/material.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/participant_tile.dart';
import '../widgets/invite_code_section.dart';
import 'connect_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  final String chatName;

  const ChatOverviewScreen({super.key, required this.chatName});

  @override
  _ChatOverviewScreenState createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  final List<Map<String, dynamic>> participants = [
    {"name": "User1233", "status": ParticipantStatus.online},
    {"name": "PetrPav_2022", "status": ParticipantStatus.away},
    {"name": "DeVil666", "status": ParticipantStatus.online},
    {"name": "User115156", "status": ParticipantStatus.offline},
    {"name": "MaoZTUnk", "status": ParticipantStatus.online},
    {"name": "Iggy", "status": ParticipantStatus.away},
    {"name": "Sajmon55", "status": ParticipantStatus.online},
    {"name": "ORlljdKf", "status": ParticipantStatus.offline},
  ];

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
          Padding(
            // Account for the transparent AppBar since extendBodyBehindAppBar=true
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            child: Column(
              children: [
                // Group chat profile picture with leave button
                Padding(
                  padding: EdgeInsets.only(top: 16, bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        child: Icon(Icons.group, size: 44, color: Colors.white),
                      ),
                      SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ConnectScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: Icon(
                            Icons.exit_to_app,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),

                // Participants header + list (flexible)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "lidé",
                              style: TextStyle(
                                fontFamily: 'Jura',
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Expanded(
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              return Transform.translate(
                                offset: Offset(0, index == 0 ? -4 : 0),
                                child: ParticipantTile(
                                  participantName: participants[index]["name"],
                                  status: participants[index]["status"],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Invite code
                InviteCodeSection(inviteCode: inviteCode),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
