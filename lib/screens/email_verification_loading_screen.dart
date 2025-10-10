import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../services/auth_service.dart';
import 'welcome_screen.dart';

class EmailVerificationLoadingScreen extends StatefulWidget {
  const EmailVerificationLoadingScreen({super.key});

  @override
  State<EmailVerificationLoadingScreen> createState() =>
      _EmailVerificationLoadingScreenState();
}

class _EmailVerificationLoadingScreenState
    extends State<EmailVerificationLoadingScreen>
    with TickerProviderStateMixin {
  final _authService = AuthService();
  Timer? _verificationTimer;
  bool _isVerified = false;
  late AnimationController _pulseController;
  late AnimationController _checkController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the loading circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _pulseController.repeat(reverse: true);

    // Check mark animation
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    _verificationTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      await _authService.reloadUser();
      if (_authService.isEmailVerified) {
        timer.cancel();
        await _handleVerificationSuccess();
      }
    });
  }

  Future<void> _handleVerificationSuccess() async {
    if (!mounted) return;

    setState(() {
      _isVerified = true;
    });

    _pulseController.stop();
    await _checkController.forward();

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // Navigate to welcome screen with slide up animation
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _verificationTimer?.cancel();
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated circle with loading or checkmark
              AnimatedBuilder(
                animation: _isVerified ? _checkAnimation : _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isVerified ? 1.0 : _pulseAnimation.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.forestGreen.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: _isVerified
                          ? ScaleTransition(
                              scale: _checkAnimation,
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 80,
                                color: AppColors.forestGreen,
                              ),
                            )
                          : Center(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.forestGreen,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // Status text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _isVerified ? 'Email Verified! ✨' : 'Verifying Your Email',
                  key: ValueKey(_isVerified),
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              if (!_isVerified)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Please check your inbox and click the verification link',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.forestGreen,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (!_isVerified) const SizedBox(height: 32),

              // Resend email button
              if (!_isVerified)
                TextButton.icon(
                  onPressed: () async {
                    try {
                      await _authService.sendVerificationEmail();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Verification email sent!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.forestGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error: ${e.toString()}',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: AppColors.deepGreen,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.email_outlined,
                    color: AppColors.forestGreen,
                  ),
                  label: Text(
                    'Resend Email',
                    style: GoogleFonts.poppins(
                      color: AppColors.forestGreen,
                      fontWeight: FontWeight.w600,
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
