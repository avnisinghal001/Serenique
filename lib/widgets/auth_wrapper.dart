import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../screens/sign_in_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/email_verification_screen.dart';
import '../screens/welcome_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Show loading indicator while waiting for auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in, check email verification and quiz completion
        if (snapshot.hasData && snapshot.data != null) {
          final user = snapshot.data!;
          if (!user.emailVerified) {
            return const EmailVerificationScreen();
          }

          // User is verified, check if quiz is completed
          return FutureBuilder<bool>(
            future: authService.hasCompletedQuiz(),
            builder: (context, quizSnapshot) {
              if (quizSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (quizSnapshot.hasData && quizSnapshot.data == true) {
                return const MainNavigationScreen();
              } else {
                // Quiz not completed - show welcome screen first
                return const WelcomeScreen();
              }
            },
          );
        }

        // If user is not logged in, show sign in screen
        return const SignInScreen();
      },
    );
  }
}
