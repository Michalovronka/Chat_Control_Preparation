import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import '../services/signalr_service.dart';

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
  final String? roomOwnerId; // ID of the room owner
  final SignalRService? signalRService; // SignalR service for kicking

  const ParticipantTile({
    super.key,
    required this.participantName,
    this.status = ParticipantStatus.offline,
    this.participantId,
    this.roomId,
    this.currentUserId,
    this.roomOwnerId,
    this.signalRService,
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
            // Only show kick button if current user is the room owner and not trying to kick themselves
            if (currentUserId != null && 
                participantId != null && 
                currentUserId != participantId &&
                roomOwnerId != null &&
                currentUserId == roomOwnerId &&
                signalRService != null &&
                roomId != null)
              IconButton(
                icon: Icon(Icons.exit_to_app, color: Colors.redAccent),
                onPressed: () async {
                  // Show confirmation dialog for kicking user
                  final shouldKick = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Vyhodit uživatele'),
                      content: Text('Opravdu chcete vyhodit $participantName?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Zrušit'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Vyhodit', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );

                  if (shouldKick == true) {
                    try {
                      // Ensure SignalR is connected
                      if (!signalRService!.isConnected) {
                        await signalRService!.start();
                        await Future.delayed(Duration(milliseconds: 500));
                      }

                      // Kick the user
                      await signalRService!.sendKick(
                        kickerUserId: currentUserId!,
                        kickedUserId: participantId!,
                        roomId: roomId!,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$participantName byl vyhozen z místnosti')),
                      );
                    } catch (e) {
                      print('Error kicking user: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Chyba při vyhazování uživatele: $e')),
                      );
                    }
                  }
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
