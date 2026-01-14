import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Pro kopírování do schránky
import 'dart:ui';
import 'chat_screen.dart';
import '../services/room_service.dart';
import '../services/app_state.dart';

class GroupChatInviteScreen extends StatefulWidget {
  final String groupName;

  const GroupChatInviteScreen({
    super.key,
    required this.groupName,
  });

  @override
  _GroupChatInviteScreenState createState() => _GroupChatInviteScreenState();
}

class _GroupChatInviteScreenState extends State<GroupChatInviteScreen> {
  String? _inviteCode;
  String? _roomId;
  bool _isCreating = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _createRoom();
  }

  Future<void> _createRoom() async {
    try {
      // Generate room ID
      final roomId = AppState.generateGuid();
      
      // Create room in backend
      final result = await RoomService.createRoom(
        roomId: roomId,
        roomName: widget.groupName,
      );

      if (result != null) {
        // Debug: print the response to see what we're getting
        print('Room creation response: $result');
        print('Response keys: ${result.keys.toList()}');
        
        setState(() {
          // Handle both camelCase and PascalCase response formats
          _roomId = result['roomId']?.toString() ?? 
                   result['RoomId']?.toString() ?? 
                   roomId;
          // Get invite code from the API response - try different possible key names
          _inviteCode = result['inviteCode']?.toString() ?? 
                       result['InviteCode']?.toString() ?? 
                       result['invite_code']?.toString();
          print('Extracted invite code: $_inviteCode');
          _isCreating = false;
        });
      } else {
        setState(() {
          _error = 'Failed to create room';
          _isCreating = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCreating) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null || _inviteCode == null || _inviteCode!.isEmpty || _roomId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _error ?? 'Failed to create room',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    String inviteCode = _inviteCode!;

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
        title: Text(
          "Vytvořit nový chat",
          style: TextStyle(
            fontFamily: 'Jura',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
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
          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          // Obsah
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nahraný obrázek nebo placeholder
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: Icon(
                      Icons.group,
                      color: Colors.white70,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Název chatu
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontFamily: 'Jura',
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 32),
                  // Zvací kód
                  Text(
                    "Zvací kód:",
                    style: TextStyle(
                      fontFamily: 'Jura',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  // Kontejner se zvacím kódem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              inviteCode,
                              style: TextStyle(
                                fontFamily: 'Jura',
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: inviteCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Kód zkopírován do schránky')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // Tlačítko Potvrdit
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to chat and remove all previous routes
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            groupName: widget.groupName,
                            roomId: _roomId!,
                          ),
                        ),
                        (route) => false, // Remove all previous routes
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    ),
                    child: Text(
                      "Potvrdit",
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
