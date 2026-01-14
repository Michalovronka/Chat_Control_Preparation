import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';

class UserProfileSection extends StatelessWidget {
  final String currentUser;
  final String? userId;

  const UserProfileSection({super.key, required this.currentUser, this.userId});

  @override
  Widget build(BuildContext context) {
    // Format user ID for display (first 8 characters with # prefix)
    final userIdDisplay = userId != null 
        ? '#${userId!.length >= 8 ? userId!.substring(0, 8) : userId!}' 
        : '#N/A';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
      },
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(Icons.person, size: 24, color: Colors.white),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                currentUser,
                style: TextStyle(
                  fontFamily: 'Jura',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfileScreen()),
                  );
                },
                child: Text(
                  userIdDisplay,
                  style: TextStyle(
                    fontFamily: 'Jura',
                    color: Colors.white70,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
