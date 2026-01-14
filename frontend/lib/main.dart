import 'package:chat_app_fe/screens/sign_in_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        fontFamily: 'Jura',
      ),
      debugShowCheckedModeBanner: false, // Remove debug banner
      home: SignInScreen(), // default screen
    );
  }
}
