import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../widgets/logout_button.dart';
import '../services/app_state.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppState _appState = AppState();
  late TextEditingController _usernameController;
  String? _userId;
  bool _isEditing = false;
  bool _isLoading = true;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = _appState.currentUserId;
    final userName = _appState.currentUserName ?? 'User';
    
    setState(() {
      _userId = userId;
      _usernameController = TextEditingController(text: userName);
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Zkopírováno do schránky'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveUsername() async {
    if (_userId == null) return;
    
    try {
      // Update username via API
      final result = await UserService.updateUser(
        userId: _userId!,
        userName: _usernameController.text,
      );
      if (result != null) {
        // Update local state
        _appState.setUser(_userId!, _usernameController.text);
        setState(() {
          _isEditing = false;
          _hasUnsavedChanges = true; // Mark that changes were saved
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Změny byly uloženy')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chyba při ukládání')),
        );
      }
    } catch (e) {
      print('Error saving username: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chyba při ukládání: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
    }

    final userIdDisplay = _userId != null 
        ? '#${_userId!.length >= 8 ? _userId!.substring(0, 8) : _userId!}' 
        : '#N/A';
    
    return WillPopScope(
      onWillPop: () async {
        // Return true to allow navigation, but we'll pass the update status via Navigator.pop
        return true;
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Container(
            margin: EdgeInsets.only(left: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () {
                      // Return true if changes were saved, false otherwise
                      Navigator.pop(context, _hasUnsavedChanges);
                    },
                  ),
                ),
              ),
            ),
          ),
        title: Text(
          "Váš profil",
          style: TextStyle(
            fontFamily: 'Jura',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
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
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          // Profilová fotka
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(Icons.person, size: 50, color: Colors.white),
                          ),
                          SizedBox(height: 24),
                          // Kartička s informacemi
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
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
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                            child: Column(
                              children: [
                                // Uživatelské jméno
                                Row(
                                  children: [
                                    Text(
                                      "uživatelské jméno: ",
                                      style: TextStyle(
                                        fontFamily: 'Jura',
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: _isEditing
                                          ? Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.2),
                                                ),
                                              ),
                                              child: TextField(
                                                controller: _usernameController,
                                                style: TextStyle(
                                                  fontFamily: 'Jura',
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                                decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                                ),
                                              ),
                                            )
                                          : Text(
                                              _usernameController.text,
                                              style: TextStyle(
                                                fontFamily: 'Jura',
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            ),
                                    ),
                                    if (!_isEditing)
                                      IconButton(
                                        icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                                        onPressed: () => _copyToClipboard(_usernameController.text),
                                        tooltip: 'Kopírovat jméno',
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                // ID uživatele
                                Row(
                                  children: [
                                    Text(
                                      "id: ",
                                      style: TextStyle(
                                        fontFamily: 'Jura',
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        userIdDisplay,
                                        style: TextStyle(
                                          fontFamily: 'Jura',
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.copy, color: Colors.white70, size: 20),
                                      onPressed: _userId != null ? () => _copyToClipboard(_userId!) : null,
                                      tooltip: 'Kopírovat ID',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          // Tlačítko Upravit/Uložit
                          Container(
                            margin: EdgeInsets.only(top: 16),
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
                                child: InkWell(
                                  onTap: () {
                                    if (_isEditing) {
                                      _saveUsername();
                                    } else {
                                      setState(() {
                                        _isEditing = true;
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                    constraints: BoxConstraints(minHeight: 50),
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _isEditing ? "Uložit" : "Upravit",
                                        style: TextStyle(
                                          fontFamily: 'Jura',
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Tlačítko Odhlásit se
                          LogoutButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
