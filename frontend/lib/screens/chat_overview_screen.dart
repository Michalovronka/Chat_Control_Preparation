import 'package:flutter/material.dart';
import '../widgets/chat_app_bar.dart';
import '../widgets/participant_tile.dart';
import '../widgets/invite_code_section.dart';
import '../services/user_service.dart';
import '../services/room_service.dart';
import '../services/app_state.dart';
import '../services/signalr_service.dart';
import 'connect_screen.dart';
import 'chat_screen.dart';

class ChatOverviewScreen extends StatefulWidget {
  final String chatName;
  final String? roomId;
  final SignalRService? signalRService; // Optional SignalR service from parent

  const ChatOverviewScreen({
    super.key, 
    required this.chatName, 
    this.roomId,
    this.signalRService,
  });

  @override
  _ChatOverviewScreenState createState() => _ChatOverviewScreenState();
}

class _ChatOverviewScreenState extends State<ChatOverviewScreen> {
  final AppState _appState = AppState();
  List<Map<String, dynamic>> participants = [];
  String? inviteCode;
  bool _isLoading = true;
  String? _currentUserId;
  SignalRService? _signalRService;

  @override
  void initState() {
    super.initState();
    _currentUserId = _appState.currentUserId;
    _signalRService = widget.signalRService;
    _loadData();
    
    // Set up SignalR listeners for real-time updates if service is available
    if (_signalRService != null) {
      _setupSignalRListeners();
    }
  }

  void _setupSignalRListeners() {
    if (_signalRService == null) return;
    
    // Listen for users joining
    _signalRService!.onReceiveJoin((data) {
      print('User joined: $data');
      // Refresh participants list
      _loadData();
    });
    
    // Listen for users leaving
    _signalRService!.onReceiveLeave((data) {
      print('User left: $data');
      // Refresh participants list
      _loadData();
    });
  }

  // Method to refresh data
  void refreshData() {
    if (widget.roomId != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (widget.roomId == null) {
      setState(() {
        _isLoading = false;
        participants = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Load participants - ensure roomId is a valid GUID
      String roomIdToUse = widget.roomId!;
      // Remove any # prefix if present
      roomIdToUse = roomIdToUse.replaceAll('#', '').trim();
      
      print('Loading participants for room: $roomIdToUse');
      final users = await UserService.getUsersByRoom(roomIdToUse);
      print('Users in room response: $users');
      
      if (users != null) {
        if (users.isNotEmpty) {
          setState(() {
            participants = users.map((user) {
              final userId = user['id'] ?? user['Id'];
              final userName = user['userName'] ?? user['UserName'] ?? 'Unknown';
              final userState = user['userState'] ?? user['UserState'] ?? 'Offline';
              print('Participant: $userName (ID: $userId, State: $userState)');
              return {
                'id': userId?.toString() ?? '',
                'name': userName,
                'status': _mapUserStateToParticipantStatus(userState),
              };
            }).where((p) => p['id'] != null && p['id']!.isNotEmpty).toList();
          });
          print('Loaded ${participants.length} participants');
        } else {
          print('No users found in room (empty list)');
          setState(() {
            participants = [];
          });
        }
      } else {
        print('No users found in room (null response)');
        setState(() {
          participants = [];
        });
      }

      // Load invite code - get room details which should include invite code
      String roomIdForInvite = widget.roomId!.replaceAll('#', '').trim();
      final room = await RoomService.getRoom(roomIdForInvite);
      if (room != null) {
        setState(() {
          inviteCode = room['inviteCode'] ?? 
                      room['InviteCode'] ?? 
                      'N/A';
        });
      } else {
        setState(() {
          inviteCode = 'N/A';
        });
      }
    } catch (e) {
      print('Error loading overview data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  ParticipantStatus _mapUserStateToParticipantStatus(String userState) {
    switch (userState.toLowerCase()) {
      case 'online':
        return ParticipantStatus.online;
      case 'away':
        return ParticipantStatus.away;
      case 'offline':
      default:
        return ParticipantStatus.offline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomIdDisplay = widget.roomId != null 
        ? '#${widget.roomId!.substring(0, 8)}' 
        : '#31161213';
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ChatAppBar(
        chatName: widget.chatName, 
        chatId: roomIdDisplay,
        fullRoomId: widget.roomId, // Pass full room ID for API calls
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
                          onPressed: () async {
                            // Leave the room via SignalR
                            if (widget.roomId != null && _currentUserId != null) {
                              try {
                                // Use existing SignalR service if available, otherwise create new one
                                SignalRService? signalRService = _signalRService;
                                bool shouldStop = false;
                                
                                if (signalRService == null) {
                                  signalRService = SignalRService();
                                  await signalRService.start();
                                  shouldStop = true;
                                  // Wait a bit for connection to establish
                                  await Future.delayed(Duration(milliseconds: 500));
                                } else {
                                  // If service exists, ensure it's connected
                                  if (!signalRService.isConnected) {
                                    await signalRService.start();
                                    // Wait a bit for connection to establish
                                    await Future.delayed(Duration(milliseconds: 500));
                                  }
                                }
                                
                                String roomIdToUse = widget.roomId!.replaceAll('#', '').trim();
                                print('Leaving room: $roomIdToUse as user: $_currentUserId');
                                
                                await signalRService.sendLeave(
                                  userId: _currentUserId!,
                                  roomId: roomIdToUse,
                                );
                                
                                print('Successfully left room');
                                
                                if (shouldStop) {
                                  await signalRService.stop();
                                }
                              } catch (e) {
                                print('Error leaving room: $e');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Chyba při opouštění místnosti: $e')),
                                );
                              }
                            }
                            
                            // Clear room from app state
                            _appState.clearRoom();
                            
                            // Navigate back to home
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
                            IconButton(
                              icon: Icon(Icons.refresh, color: Colors.white70),
                              onPressed: refreshData,
                              tooltip: 'Obnovit',
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Expanded(
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white70,
                                  ),
                                )
                              : participants.isEmpty
                                  ? Center(
                                      child: Text(
                                        'Žádní účastníci',
                                        style: TextStyle(
                                          fontFamily: 'Jura',
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: participants.length,
                                      itemBuilder: (context, index) {
                                        return Transform.translate(
                                          offset: Offset(0, index == 0 ? -4 : 0),
                                          child: ParticipantTile(
                                            participantId: participants[index]["id"]?.toString(),
                                            participantName: participants[index]["name"],
                                            status: participants[index]["status"],
                                            roomId: widget.roomId,
                                            currentUserId: _currentUserId,
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
                InviteCodeSection(inviteCode: inviteCode ?? 'N/A'),
                SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
