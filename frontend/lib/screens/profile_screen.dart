import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _usernameController = TextEditingController(text: "user123");
  final String _userId = "#09875557876";
  bool _isEditing = false;
  File? _profileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          "Váš profil",
          style: TextStyle(
            fontFamily: 'Jura',
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
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
          // Obsah s marginem a paddingem
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 240),
            child: Column(
              children: [
                SizedBox(height: 20),
                // Profilová fotka
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : null,
                    child: _profileImage == null
                        ? Icon(Icons.person, size: 50, color: Colors.white)
                        : null,
                  ),
                ),
                SizedBox(height: 24),
                // Kartička s informacemi
                Container(
                  padding: EdgeInsets.all(16),
                  margin: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
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
                          Text(
                            _userId,
                            style: TextStyle(
                              fontFamily: 'Jura',
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                // Tlačítko Upravit/Uložit
                Container(
                  margin: EdgeInsets.only(top: 16),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_isEditing) {
                        setState(() {
                          _isEditing = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Změny byly uloženy')),
                        );
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      _isEditing ? "Uložit" : "Upravit",
                      style: TextStyle(
                        fontFamily: 'Jura',
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
