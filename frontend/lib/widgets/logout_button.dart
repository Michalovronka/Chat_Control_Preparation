import 'package:flutter/material.dart';
import '../screens/sign_in_screen.dart';
import '../services/app_state.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Clear authentication state
        AppState().clear();
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        minimumSize: Size(double.infinity, 50),
      ),
      child: Text(
        "Odhlásit se",
        style: TextStyle(
          fontFamily: 'Jura',
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}
