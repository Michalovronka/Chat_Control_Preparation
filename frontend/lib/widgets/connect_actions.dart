import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../screens/create_group_chat_screen.dart';

class ConnectActions extends StatelessWidget {
  const ConnectActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(groupName: "Nový Chat"),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 0, 255, 170),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              "Připojit se",
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateGroupChatScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
