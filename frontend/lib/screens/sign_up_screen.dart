import 'package:flutter/material.dart';
import 'dart:ui';
import 'sign_in_screen.dart';
import 'connect_screen.dart';

class SignUpScreen
    extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState
    extends State<SignUpScreen> {
  final TextEditingController
  _emailController =
      TextEditingController();
  final TextEditingController
  _passwordController =
      TextEditingController();
  final TextEditingController
  _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(
            left: 16,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
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
                    "Registrace",
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
                  // Email input
                  _buildGlassInput(
                    controller:
                        _emailController,
                    hintText: "Email",
                    icon: Icons.email,
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
                  SizedBox(height: 16),
                  // Confirm Password input
                  _buildGlassInput(
                    controller:
                        _confirmPasswordController,
                    hintText:
                        "Potvrďte heslo",
                    icon: Icons.lock,
                    isPassword: true,
                  ),
                  SizedBox(height: 32),
                  // Registrace tlačítko
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        // Nahradí aktuální screen v stacku
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) =>
                                  ConnectScreen(),
                        ),
                      );
                    },
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
                    ),
                    child: Text(
                      "Zaregistrovat se",
                      style: TextStyle(
                        fontFamily:
                            'Jura',
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,
                    children: [
                      Text(
                        "Máte účet? ",
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
                                      SignInScreen(),
                            ),
                          );
                        },
                        child: Text(
                          "Přihlaste se",
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
