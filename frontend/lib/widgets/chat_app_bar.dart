import 'package:flutter/material.dart';
import '../screens/chat_overview_screen.dart';
import '../screens/connect_screen.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String chatName;
  final String chatId;

  const ChatAppBar({super.key, required this.chatName, required this.chatId});

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConnectScreen(),
                ),
              );
            }
          },
        ),
      ),
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatOverviewScreen(chatName: chatName),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chatName,
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white.withOpacity(0.8),
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
            Text(
              chatId,
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
