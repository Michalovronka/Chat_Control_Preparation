import 'package:flutter/material.dart';
import '../widgets/user_profile_section.dart';
import '../widgets/chat_tile.dart';
import '../widgets/forum_code_input.dart';
import '../widgets/connect_actions.dart';
import '../services/app_state.dart';
import '../services/room_service.dart';
import 'chat_screen.dart';
import 'sign_in_screen.dart';

class ConnectScreen extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  _ConnectScreenState createState() => _ConnectScreenState();
}

class _ConnectScreenState extends State<ConnectScreen> {
  final TextEditingController _codeController = TextEditingController();
  final AppState _appState = AppState();
  bool _isInitializing = true;
  bool _isLoadingRooms = true;
  List<Map<String, dynamic>> _userRooms = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  // Method to refresh rooms (can be called when returning to screen)
  void refreshRooms() {
    if (!_isInitializing && _appState.currentUserId != null) {
      _loadUserRooms();
    }
  }

  Future<void> _initializeUser() async {
    // Check if user is already authenticated
    if (_appState.currentUserId == null || _appState.currentUserName == null) {
      // User not authenticated, redirect to sign in
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
        );
      }
      return;
    }

    // Load user's rooms
    await _loadUserRooms();

    setState(() {
      _isInitializing = false;
    });
  }

  Future<void> _loadUserRooms() async {
    if (_appState.currentUserId == null) return;

    setState(() {
      _isLoadingRooms = true;
    });

    try {
      final rooms = await RoomService.getRoomsByUser(_appState.currentUserId!);
      if (rooms != null) {
        setState(() {
          _userRooms = rooms.map((room) {
            final roomId = room['id'] ?? room['Id'];
            final roomName = room['roomName'] ?? room['RoomName'] ?? 'Unknown Room';
            return {
              'id': roomId?.toString() ?? '',
              'name': roomName,
            };
          }).toList();
          _isLoadingRooms = false;
        });
      } else {
        setState(() {
          _isLoadingRooms = false;
        });
      }
    } catch (e) {
      print('Error loading user rooms: $e');
      setState(() {
        _isLoadingRooms = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentUser = _appState.currentUserName ?? "Guest";
    final userId = _appState.currentUserId ?? "unknown";

    return Scaffold(
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
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 60),
                UserProfileSection(currentUser: currentUser),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vaše fóra",
                    style: TextStyle(
                      fontFamily: 'Jura',
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: _isLoadingRooms
                      ? Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      : _userRooms.isEmpty
                          ? Center(
                              child: Text(
                                'Žádná fóra',
                                style: TextStyle(
                                  fontFamily: 'Jura',
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _userRooms.length,
                              itemBuilder: (context, index) {
                                return ChatTile(
                                  name: _userRooms[index]["name"] ?? "Unknown",
                                  id: _userRooms[index]["id"] ?? "",
                                );
                              },
                            ),
                ),
                ForumCodeInput(codeController: _codeController),
                ConnectActions(
                  onConnectPressed: () async {
                    // Handle room code join
                    // Normalize code: remove #, trim, and convert to uppercase
                    final code = _codeController.text.trim().replaceAll('#', '').toUpperCase();
                    if (code.isNotEmpty) {
                      // Look up room by invite code
                      print('Looking up room with code: $code');
                      final room = await RoomService.getRoomByCode(code);
                      print('Room lookup result: $room');
                      // Handle both camelCase and PascalCase response formats
                      final roomId = room?['id'] ?? room?['Id'];
                      final roomName = room?['roomName'] ?? room?['RoomName'];
                      if (room != null && roomId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              groupName: roomName ?? "Room",
                              roomId: roomId.toString(),
                            ),
                          ),
                        ).then((_) {
                          // Refresh rooms when returning from chat
                          refreshRooms();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Room not found')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a room code')),
                      );
                    }
                  },
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
