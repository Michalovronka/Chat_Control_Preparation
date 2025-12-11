import 'package:chat_app_fe/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'screens/connect_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        fontFamily: 'Jura',
      ),
      home: SignInScreen(), // default screen
    );
  }
}
