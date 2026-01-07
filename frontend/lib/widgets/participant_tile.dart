import 'package:flutter/material.dart';

class ParticipantTile extends StatelessWidget {
  final String participantName;

  const ParticipantTile({Key? key, required this.participantName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Colors.white70),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.redAccent),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
