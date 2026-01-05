import 'package:flutter/material.dart';
import 'dart:ui';
import 'chat_screen.dart';

class ConnectScreen
    extends StatefulWidget {
  const ConnectScreen({super.key});

  @override
  _ConnectScreenState createState() =>
      _ConnectScreenState();
}

class _ConnectScreenState
    extends State<ConnectScreen> {
  final TextEditingController
  _codeController =
      TextEditingController();
  final String _currentUser =
      "user#09875557876"; // Příklad aktuálně přihlášeného uživatele

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradientové pozadí (stejné jako v chat_screen)
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
          // Lehké ztmavení pro lepší čitelnost
          Container(
            color: Colors.black
                .withOpacity(0.2),
          ),
          // Obsah
          Center(
            child: Padding(
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
                    "Připojte se k fóru...",
                    style: TextStyle(
                      fontFamily:
                          'Jura',
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                  SizedBox(height: 32),
                  // user avatar
                  CircleAvatar(
                    radius: 48,
                    backgroundColor:
                        Colors.white
                            .withOpacity(
                              0.2,
                            ),
                    child: Icon(
                      Icons.person,
                      size: 48,
                      color:
                          Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  // user ID
                  Text(
                    _currentUser,
                    style: TextStyle(
                      fontFamily:
                          'Jura',
                      color:
                          Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 48),
                  // forum code input
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(
                          20,
                        ),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(
                            sigmaX: 10,
                            sigmaY: 10,
                          ),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(
                              horizontal:
                                  20,
                              vertical:
                                  4,
                            ),
                        decoration: BoxDecoration(
                          color: Colors
                              .white
                              .withOpacity(
                                0.15,
                              ),
                          borderRadius:
                              BorderRadius.circular(
                                20,
                              ),
                          border: Border.all(
                            color: Colors
                                .white
                                .withOpacity(
                                  0.2,
                                ),
                          ),
                        ),
                        child: TextField(
                          controller:
                              _codeController,
                          style: TextStyle(
                            fontFamily:
                                'Jura',
                            color: Colors
                                .white,
                            fontSize:
                                18,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                "zadejte kód fóra...",
                            hintStyle: TextStyle(
                              fontFamily:
                                  'Jura',
                              color: Colors
                                  .white70,
                              fontSize:
                                  18,
                            ),
                            border:
                                InputBorder
                                    .none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Tlačítko pro připojení
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) =>
                                  ChatScreen(),
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
                      "Připojit se",
                      style: TextStyle(
                        fontFamily:
                            'Jura',
                        color: const Color.fromARGB(255, 0, 0, 0),
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Text "nebo"
                  Text(
                    "nebo",
                    style: TextStyle(
                      fontFamily:
                          'Jura',
                      color: Colors
                          .white70,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 24),
                  // Tlačítko pro vytvoření nového fóra
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors
                            .white
                            .withOpacity(
                              0.4,
                            ),
                      ),
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
                      "Vytvořit nové fórum",
                      style: TextStyle(
                        fontFamily:
                            'Jura',
                        color: Colors
                            .white,
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
