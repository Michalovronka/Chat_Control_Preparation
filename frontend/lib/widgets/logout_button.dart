import 'package:flutter/material.dart';
import 'dart:ui';
import '../screens/sign_in_screen.dart';
import '../services/app_state.dart';
import '../services/signalr_service.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: () async {
              // Stop SignalR so we never reuse the same connection across users.
              // Reusing causes "Invocation canceled... connection being closed" when
              // loading messages after login (e.g. Lukas → Pavel → Lukas, then open room).
              try {
                await SignalRService().stop();
              } catch (e) {
                // Ignore stop errors
              }
              // Clear authentication state
              AppState().clear();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
                (route) => false,
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              constraints: BoxConstraints(minHeight: 50),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  "Odhlásit se",
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
    );
  }
}
