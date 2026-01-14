import 'package:flutter/material.dart';
import 'dart:ui';
import '../widgets/user_profile_section.dart';
import '../widgets/chat_tile.dart';
import '../widgets/forum_code_input.dart';
import '../widgets/connect_actions.dart';
import '../services/app_state.dart';
import '../services/room_service.dart';
import '../services/user_service.dart';
import '../services/signalr_service.dart';
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
  final SignalRService _signalRService = SignalRService();
  bool _isInitializing = true;
  bool _isLoadingRooms = true;
  List<Map<String, dynamic>> _userRooms = [];

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _setupSignalR();
  }

  @override
  void dispose() {
    _signalRService.stop();
    super.dispose();
  }

  Future<void> _setupSignalR() async {
    try {
      // Set up listener for received invites (queries)
      _signalRService.onReceiveQuery((data) {
        print('[INVITE RECEIVED] Processing invite in connect_screen: $data');
        final senderUserId = (data['SenderUserId'] ?? data['senderUserId'])?.toString();
        final receiverUserId = (data['ReceiverUserId'] ?? data['receiverUserId'])?.toString();
        final roomId = (data['RoomId'] ?? data['roomId'])?.toString();
        
        print('[INVITE RECEIVED] Parsed - Sender: $senderUserId, Receiver: $receiverUserId, Room: $roomId, CurrentUser: ${_appState.currentUserId}');
        
        // Check if this invite is for the current user
        if (senderUserId != null && roomId != null && receiverUserId == _appState.currentUserId) {
          print('[INVITE RECEIVED] Invite is for current user, fetching sender info...');
          // Get sender's username and store the invite
          UserService.getUser(senderUserId).then((user) {
            if (user != null && mounted) {
              final senderUserName = (user['UserName'] ?? user['userName'])?.toString() ?? 'Unknown User';
              print('[INVITE RECEIVED] Adding invite to AppState - Sender: $senderUserName ($senderUserId), Room: $roomId');
              _appState.addInvite(senderUserId, senderUserName, roomId);
              setState(() {
                // Trigger rebuild to show new invite
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Pozvánka od $senderUserName')),
              );
              print('[INVITE RECEIVED] Invite successfully added and displayed');
            } else {
              print('[INVITE ERROR] Could not fetch sender user info or widget not mounted');
            }
          });
        } else {
          print('[INVITE ERROR] Invite validation failed - Sender: $senderUserId, Room: $roomId, Receiver matches: ${receiverUserId == _appState.currentUserId}');
        }
      });

      // Connect to SignalR
      if (_appState.currentUserId != null) {
        await _signalRService.start();
        // Register the connection so the user can receive invites
        await _signalRService.registerConnection(_appState.currentUserId!);
      }
    } catch (e) {
      print('Error setting up SignalR for invites: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh rooms when screen becomes visible again
    if (!_isInitializing) {
      refreshRooms();
    }
  }

  // Method to refresh rooms (can be called when returning to screen)
  void refreshRooms() {
    if (!_isInitializing && _appState.currentUserId != null) {
      _loadUserRooms();
    }
  }

  Future<void> _acceptInvite(String senderUserId, String roomId) async {
    if (_appState.currentUserId == null) return;

    try {
      // Get room info to get the room name
      final room = await RoomService.getRoom(roomId);
      if (room == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Místnost nenalezena')),
        );
        return;
      }

      final roomName = (room['roomName'] ?? room['RoomName'])?.toString() ?? 'Room';

      // Ensure SignalR is connected
      if (!_signalRService.isConnected) {
        await _signalRService.start();
        await Future.delayed(Duration(milliseconds: 500));
      }

      // Join the room (this will add room to user's JoinedRooms and user to room's JoinedUsers)
      await _signalRService.sendJoin(
        userId: _appState.currentUserId!,
        roomId: roomId,
      );

      // Remove the invite
      _appState.removeInvite(senderUserId, roomId);
      setState(() {});

      // Navigate to the chat screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            groupName: roomName,
            roomId: roomId,
          ),
        ),
      ).then((_) {
        // Refresh rooms when returning from chat
        refreshRooms();
      });
    } catch (e) {
      print('Error accepting invite: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba při přijímání pozvánky: $e')),
      );
    }
  }

  void _declineInvite(String senderUserId, String roomId) {
    _appState.removeInvite(senderUserId, roomId);
    setState(() {});
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

    // Get fresh values from app state each time build is called
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
                UserProfileSection(
                  currentUser: _appState.currentUserName ?? "Guest", 
                  userId: _appState.currentUserId ?? "unknown",
                  onProfileUpdated: () {
                    // Refresh user data when returning from profile
                    setState(() {
                      // This will trigger a rebuild with updated user name from AppState
                    });
                  },
                ),
                SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Joined rooms section
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
                        _isLoadingRooms
                            ? Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: CircularProgressIndicator(
                                    color: Colors.white70,
                                  ),
                                ),
                              )
                            : _userRooms.isEmpty
                                ? Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      'Žádná fóra',
                                      style: TextStyle(
                                        fontFamily: 'Jura',
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  )
                                : Column(
                                    children: List.generate(_userRooms.length, (index) {
                                      return ChatTile(
                                        name: _userRooms[index]["name"] ?? "Unknown",
                                        id: _userRooms[index]["id"] ?? "",
                                      );
                                    }),
                                  ),
                        SizedBox(height: 20),
                        // Invites section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Pozvánky",
                            style: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        _appState.receivedInvites.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  'Žádné pozvánky',
                                  style: TextStyle(
                                    fontFamily: 'Jura',
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Column(
                                children: List.generate(_appState.receivedInvites.length, (index) {
                                  final invite = _appState.receivedInvites[index];
                                  final senderUserId = invite['senderUserId']?.toString() ?? '';
                                  final senderUserName = invite['senderUserName']?.toString() ?? 'Unknown User';
                                  final roomId = invite['roomId']?.toString() ?? '';
                                  return Container(
                                    margin: EdgeInsets.symmetric(vertical: 4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withOpacity(0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: Colors.white.withOpacity(0.2),
                                                child: Icon(Icons.forum, color: Colors.white, size: 18),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Pozvánka od $senderUserName',
                                                      style: TextStyle(
                                                        fontFamily: 'Jura',
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    Text(
                                                      roomId.length >= 8 ? '#${roomId.substring(0, 8)}' : roomId,
                                                      style: TextStyle(
                                                        fontFamily: 'Jura',
                                                        color: Colors.white70,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              // Accept button
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.green.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.green.withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.check, color: Colors.white, size: 20),
                                                  onPressed: () => _acceptInvite(senderUserId, roomId),
                                                  tooltip: 'Přijmout',
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              // Decline button
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.red.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.red.withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: IconButton(
                                                  icon: Icon(Icons.close, color: Colors.white, size: 20),
                                                  onPressed: () => _declineInvite(senderUserId, roomId),
                                                  tooltip: 'Odmítnout',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                      ],
                    ),
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
