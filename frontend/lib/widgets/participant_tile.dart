import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';

enum ParticipantStatus {
  online,
  away,
  offline,
}

class ParticipantTile extends StatelessWidget {
  final String participantName;
  final ParticipantStatus status;
  final String? participantId;
  final String? roomId;
  final String? currentUserId;

  const ParticipantTile({
    super.key,
    required this.participantName,
    this.status = ParticipantStatus.offline,
    this.participantId,
    this.roomId,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: Icon(Icons.person, color: Colors.white),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _getStatusColor(),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
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
              onPressed: participantId != null && roomId != null
                  ? () {
                      // Navigate to chat screen with this user (private chat)
                      // For now, navigate to the same room
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            groupName: participantName,
                            roomId: roomId,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
            if (currentUserId != null && participantId != null && currentUserId != participantId)
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.redAccent),
                onPressed: () {
                  // Show confirmation dialog for kicking user
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Vyhodit uživatele'),
                      content: Text('Opravdu chcete vyhodit ${participantName}?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Zrušit'),
                        ),
                        TextButton(
                          onPressed: () {
                            // TODO: Implement kick user functionality
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Funkce vyhození uživatele bude implementována')),
                            );
                          },
                          child: Text('Vyhodit', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case ParticipantStatus.online:
        return Colors.green;
      case ParticipantStatus.away:
        return Colors.yellow;
      case ParticipantStatus.offline:
        return Colors.grey;
    }
  }
}
