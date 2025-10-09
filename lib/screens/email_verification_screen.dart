import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../utils/app_colors.dart';
import 'main_navigation_screen.dart';
import 'sign_in_screen.dart';
import 'email_verification_debug_screen.dart';
import 'quiz_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final AuthService _authService = AuthService();
  Timer? _timer;
  bool _isVerified = false;
  bool _isResending = false;
  DateTime? _lastEmailSent;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _checkEmailVerification() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _authService.reloadUser();
      if (_authService.isEmailVerified) {
        setState(() {
          _isVerified = true;
        });
        timer.cancel();

        // Check if user has completed quiz
        final hasCompletedQuiz = await _authService.hasCompletedQuiz();

        // Navigate to quiz if not completed, otherwise to home screen
        if (mounted) {
          if (hasCompletedQuiz) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const QuizScreen()),
            );
          }
        }
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    // Check if we can send another email (rate limiting)
    if (_lastEmailSent != null) {
      final timeSinceLastEmail = DateTime.now().difference(_lastEmailSent!);
      if (timeSinceLastEmail.inSeconds < 60) {
        final waitTime = 60 - timeSinceLastEmail.inSeconds;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Please wait $waitTime seconds before requesting another email.',
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
        return;
      }
    }

    setState(() {
      _isResending = true;
    });

    try {
      await _authService.sendVerificationEmail();
      _lastEmailSent = DateTime.now();
      print('Verification email sent to: ${_authService.currentUser!.email}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Verification email sent! Check your inbox and spam folder.',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('Error sending verification email: $e');
      String errorMessage = e.toString();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      setState(() {
        _isResending = false;
      });
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _authService.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Email verification icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.sageGreen.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.email_outlined,
                  size: 60,
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Email',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'We\'ve sent a verification email to:\n$userEmail',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.deepGreen,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Instructions
              Text(
                'Please check your email and click the verification link to activate your account.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.deepGreen,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '⚠️ Check your spam/junk folder if you don\'t see the email',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Loading indicator
              if (!_isVerified) ...[
                CircularProgressIndicator(
                  color: AppColors.forestGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  'Waiting for verification...',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.deepGreen,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Resend button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: _isResending ? null : _resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.forestGreen),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isResending
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.forestGreen,
                          ),
                        )
                      : Text(
                          'Resend Verification Email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.forestGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Sign out button
              TextButton(
                onPressed: _signOut,
                child: Text(
                  'Use Different Account',
                  style: GoogleFonts.poppins(
                    color: AppColors.deepGreen,
                    fontSize: 14,
                  ),
                ),
              ),

              // Temporary skip button for testing
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      '⚠️ Firebase Rate Limiting Active',
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Firebase has temporarily blocked email requests. Wait 10 minutes or use skip for testing.',
                      style: GoogleFonts.poppins(
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // For testing purposes - skip verification
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MainNavigationScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip Verification (Testing Only)',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Debug button
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          const EmailVerificationDebugScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.bug_report,
                  size: 16,
                  color: AppColors.deepGreen,
                ),
                label: Text(
                  'Debug Info',
                  style: GoogleFonts.poppins(
                    color: AppColors.deepGreen,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
