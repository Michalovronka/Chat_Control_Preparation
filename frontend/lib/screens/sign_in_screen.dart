import 'package:flutter/material.dart';
import 'dart:ui';
import 'sign_up_screen.dart';
import 'connect_screen.dart';
import '../services/auth_service.dart';
import '../services/app_state.dart';

class SignInScreen
    extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() =>
      _SignInScreenState();
}

class _SignInScreenState
    extends State<SignInScreen> {
  final TextEditingController
  _usernameController =
      TextEditingController();
  final TextEditingController
  _passwordController =
      TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Gradientové pozadí
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin:
                    Alignment.topLeft,
                end: Alignment
                    .bottomRight,
                colors: [
                  Colors.black,
                  Color(0xFF1a0a2a),
                  Color(0xFF133e52),
                  Color(0xFF0a2a1a),
                  Colors.black,
                ],
                stops: [
                  0.0,
                  0.25,
                  0.5,
                  0.75,
                  1.0,
                ],
              ),
            ),
          ),
          // Lehké ztmavení
          Container(
            color: Colors.black
                .withOpacity(0.2),
          ),
          // Obsah
          Center(
            child: SingleChildScrollView(
              padding:
                  EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                children: [
                  Text(
                    "Přihlásit se",
                    style: TextStyle(
                      fontFamily:
                          'Jura',
                      color:
                          Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  SizedBox(height: 48),
                  // Error message
                  if (_errorMessage != null)
                    Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          fontFamily: 'Jura',
                          color: Colors.red[200],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  // Username input
                  _buildGlassInput(
                    controller:
                        _usernameController,
                    hintText: "Uživatelské jméno",
                    icon: Icons.person,
                  ),
                  SizedBox(height: 16),
                  // Password input
                  _buildGlassInput(
                    controller:
                        _passwordController,
                    hintText: "Heslo",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 32),
                  // Přihlášení tlačítko
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 0, 255, 170),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                              20,
                            ),
                      ),
                      padding:
                          EdgeInsets.symmetric(
                            horizontal:
                                32,
                            vertical:
                                16,
                          ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                            ),
                          )
                        : Text(
                            "Přihlásit se",
                            style: TextStyle(
                              fontFamily:
                                  'Jura',
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontSize: 18,
                            ),
                          ),
                  ),
                  SizedBox(height: 24),
                  // "Nemáte účet? Zaregistrujte se"
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        "Nemáte účet? ",
                        style: TextStyle(
                          fontFamily:
                              'Jura',
                          color: Colors
                              .white70,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            // Nahradí aktuální screen
                            context,
                            MaterialPageRoute(
                              builder:
                                  (
                                    context,
                                  ) =>
                                      SignUpScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Zaregistrujte se",
                          style: TextStyle(
                            fontFamily:
                                'Jura',
                            color: Colors
                                .blueAccent,
                            fontSize:
                                16,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Prosím vyplňte všechna pole';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await AuthService.login(username, password);
      
      if (result != null && result['error'] == null) {
        // Login successful
        try {
          final appState = AppState();
          // Safely extract values with proper type handling
          // Try both PascalCase and camelCase
          final userIdValue = result['UserId'] ?? result['userId'];
          final userNameValue = result['UserName'] ?? result['userName'];
          
          print('Raw result: $result'); // Debug
          print('userIdValue: $userIdValue (type: ${userIdValue.runtimeType})'); // Debug
          print('userNameValue: $userNameValue (type: ${userNameValue.runtimeType})'); // Debug
          
          String userId = '';
          String userName = username;
          
          if (userIdValue != null) {
            if (userIdValue is String) {
              userId = userIdValue;
            } else {
              userId = userIdValue.toString();
            }
          }
          
          if (userNameValue != null) {
            if (userNameValue is String) {
              userName = userNameValue;
            } else {
              userName = userNameValue.toString();
            }
          }
          
          print('Setting user - userId: "$userId", userName: "$userName"'); // Debug
          
          if (userId.isNotEmpty && userName.isNotEmpty) {
            appState.setUser(userId, userName);
            
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ConnectScreen(),
                ),
              );
            }
          } else {
            setState(() {
              _errorMessage = 'Login succeeded but failed to get user information';
              _isLoading = false;
            });
          }
        } catch (e) {
          setState(() {
            _errorMessage = 'Error processing login: $e';
            _isLoading = false;
          });
        }
      } else {
        // Login failed
        setState(() {
          _errorMessage = result?['error'] ?? 'Přihlášení selhalo';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Chyba: $e';
        _isLoading = false;
      });
    }
  }

  // Pomocná metoda pro vytvoření glass inputu
  Widget _buildGlassInput({
    required TextEditingController
    controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.15),
            borderRadius:
                BorderRadius.circular(
                  20,
                ),
            border: Border.all(
              color: Colors.white
                  .withOpacity(0.2),
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            style: TextStyle(
              fontFamily: 'Jura',
              color: Colors.white,
              fontSize: 18,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white70,
                fontSize: 18,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: Colors.white70,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
