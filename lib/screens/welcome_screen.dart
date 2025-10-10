import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _avatarController;
  late AnimationController _bubbleController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _avatarScaleAnimation;
  late Animation<double> _bubbleScaleAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize all controllers first
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bubbleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Then initialize all animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _avatarScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _bubbleScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bubbleController, curve: Curves.easeOutBack),
    );

    _floatingAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Start animations in sequence
    _controller.forward().then((_) {
      _avatarController.forward().then((_) {
        _bubbleController.forward().then((_) {
          _floatingController.repeat(reverse: true);
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _avatarController.dispose();
    _bubbleController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        // Serebot Avatar with Floating Animation
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: child,
                            );
                          },
                          child: ScaleTransition(
                            scale: _avatarScaleAnimation,
                            child: _buildSerebotAvatar(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Comic Speech Bubble
                        ScaleTransition(
                          scale: _bubbleScaleAnimation,
                          child: _buildSpeechBubble(),
                        ),
                        const SizedBox(height: 30),

                        // Welcome message
                        Text(
                          'Welcome to Serenique',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Description card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.sageGreen.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Your Journey to Inner Peace',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGreen,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'I\'m here to support your mental wellness journey. '
                                'To provide you with personalized care, '
                                'I\'d love to get to know you better through a brief questionnaire.\n\n'
                                'This will help me create a peaceful, tailored experience just for you.',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.forestGreen,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Begin button with press animation
                        _buildAnimatedButton(),
                        const SizedBox(height: 12),

                        // Encouraging text with sparkle animation
                        _buildSparkleText(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSerebotAvatar() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.sageGreen.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Avatar illustration (Open Peeps style)
          Center(
            child: CustomPaint(
              size: const Size(100, 100),
              painter: SerebotAvatarPainter(),
            ),
          ),
          // Decorative elements
          Positioned(
            top: 10,
            right: 15,
            child: Container(
              width: 25,
              height: 25,
              decoration: BoxDecoration(
                color: AppColors.sageGreen.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('✨', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.darkGreen, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGreen.withOpacity(0.15),
                blurRadius: 0,
                offset: const Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Hi! I\'m Serebot',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(width: 8),
              const Text('🌸', style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        // Speech bubble tail
        Positioned(
          top: -12,
          left: 60,
          child: CustomPaint(
            size: const Size(20, 15),
            painter: SpeechBubbleTailPainter(color: AppColors.darkGreen),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: () {
          // Simple navigation without complex transitions
          if (!context.mounted) return;
          
          Navigator.of(context).pushReplacementNamed('/quiz');
        },
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.forestGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        child: Text(
          'Begin Your Journey  →',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSparkleText() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Opacity(opacity: 0.5 + (0.5 * value), child: child);
      },
      child: Text(
        '✨ A calming space awaits you ✨',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.sageGreen,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// Custom painter for Serebot Avatar (Open Peeps inspired)
class SerebotAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Face
    paint.color = const Color(0xFF2D5F3F);
    canvas.drawCircle(Offset(centerX, centerY), 35, paint);

    // Eyes (happy closed eyes)
    paint.strokeWidth = 2.5;
    // Left eye
    final leftEyePath = Path();
    leftEyePath.moveTo(centerX - 15, centerY - 5);
    leftEyePath.quadraticBezierTo(
      centerX - 10,
      centerY - 8,
      centerX - 5,
      centerY - 5,
    );
    canvas.drawPath(leftEyePath, paint);

    // Right eye
    final rightEyePath = Path();
    rightEyePath.moveTo(centerX + 5, centerY - 5);
    rightEyePath.quadraticBezierTo(
      centerX + 10,
      centerY - 8,
      centerX + 15,
      centerY - 5,
    );
    canvas.drawPath(rightEyePath, paint);

    // Smile
    paint.strokeWidth = 3.0;
    final smilePath = Path();
    smilePath.moveTo(centerX - 12, centerY + 8);
    smilePath.quadraticBezierTo(
      centerX,
      centerY + 18,
      centerX + 12,
      centerY + 8,
    );
    canvas.drawPath(smilePath, paint);

    // Hair (wavy lines)
    paint.strokeWidth = 2.5;
    final hairPath1 = Path();
    hairPath1.moveTo(centerX - 20, centerY - 25);
    hairPath1.quadraticBezierTo(
      centerX - 15,
      centerY - 30,
      centerX - 10,
      centerY - 28,
    );
    canvas.drawPath(hairPath1, paint);

    final hairPath2 = Path();
    hairPath2.moveTo(centerX, centerY - 30);
    hairPath2.quadraticBezierTo(
      centerX + 5,
      centerY - 35,
      centerX + 10,
      centerY - 30,
    );
    canvas.drawPath(hairPath2, paint);

    final hairPath3 = Path();
    hairPath3.moveTo(centerX + 15, centerY - 28);
    hairPath3.quadraticBezierTo(
      centerX + 20,
      centerY - 30,
      centerX + 25,
      centerY - 25,
    );
    canvas.drawPath(hairPath3, paint);

    // Leaf accessory
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFF7FA88E);
    final leafPath = Path();
    leafPath.moveTo(centerX + 25, centerY - 20);
    leafPath.quadraticBezierTo(
      centerX + 30,
      centerY - 18,
      centerX + 28,
      centerY - 12,
    );
    leafPath.quadraticBezierTo(
      centerX + 25,
      centerY - 15,
      centerX + 25,
      centerY - 20,
    );
    canvas.drawPath(leafPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for speech bubble tail
class SpeechBubbleTailPainter extends CustomPainter {
  final Color color;

  SpeechBubbleTailPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);

    // Border
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final borderPath = Path();
    borderPath.moveTo(size.width / 2, size.height);
    borderPath.lineTo(0, 0);

    canvas.drawPath(borderPath, borderPaint);

    final borderPath2 = Path();
    borderPath2.moveTo(size.width / 2, size.height);
    borderPath2.lineTo(size.width, 0);

    canvas.drawPath(borderPath2, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
