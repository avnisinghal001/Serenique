import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import '../utils/quiz_data.dart';
import '../services/auth_service.dart';
import 'congratulations_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  final Map<int, String> _answers = {};
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers first
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Then create animations
    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _selectOption(String option) {
    if (_isAnimating) return;

    setState(() {
      _selectedOption = option;
    });

    // Animate selection with a slight delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _answers[quizQuestions[_currentQuestionIndex].id] = option;
        _nextQuestion();
      }
    });
  }

  void _previousQuestion() async {
    if (_isAnimating || _currentQuestionIndex == 0) return;

    setState(() {
      _isAnimating = true;
    });

    // Fade out current question
    await _fadeController.reverse();

    // Move to previous question
    setState(() {
      _currentQuestionIndex--;
      // Load previously selected answer if exists
      _selectedOption = _answers[quizQuestions[_currentQuestionIndex].id];
    });

    // Slide and fade in previous question
    _slideController.reset();
    await _slideController.forward();
    await _fadeController.forward();

    setState(() {
      _isAnimating = false;
    });
  }

  void _nextQuestion() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Fade out current question
    await _fadeController.reverse();

    if (_currentQuestionIndex < quizQuestions.length - 1) {
      // Move to next question
      setState(() {
        _currentQuestionIndex++;
        _selectedOption = null;
      });

      // Slide and fade in next question
      _slideController.reset();
      await _slideController.forward();
      await _fadeController.forward();

      setState(() {
        _isAnimating = false;
      });
    } else {
      // Quiz completed - save responses and navigate to congratulations
      await _saveQuizResponses();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const CongratulationsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    }
  }

  Future<void> _saveQuizResponses() async {
    try {
      await AuthService().saveQuizResponses(_answers);
    } catch (e) {
      print('Error saving quiz responses: $e');
    }
  }

  @override
  Widget build(BuildContext context) {

    final question = quizQuestions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / quizQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.lightBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentQuestionIndex > 0
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.darkGreen),
                onPressed: _previousQuestion,
              )
            : null,
        actions: [
          // Debug: Sign out button (remove in production)
          IconButton(
            icon: Icon(
              Icons.logout,
              color: AppColors.darkGreen.withOpacity(0.5),
            ),
            tooltip: 'Sign Out',
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/', (route) => false);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${_currentQuestionIndex + 1} of ${quizQuestions.length}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.forestGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      tween: Tween<double>(begin: 0.0, end: progress),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        backgroundColor: AppColors.sageGreen.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.forestGreen,
                        ),
                        minHeight: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Question and options
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Question text
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkGreen.withOpacity(0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Text(
                            question.question,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGreen,
                              height: 1.4,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Options
                        ...question.options.map((option) {
                          final isSelected = _selectedOption == option.letter;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _OptionCard(
                              letter: option.letter,
                              text: option.text,
                              isSelected: isSelected,
                              onTap: () => _selectOption(option.letter),
                            ),
                          );
                        }),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatefulWidget {
  final String letter;
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.letter,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_OptionCard> createState() => _OptionCardState();
}

class _OptionCardState extends State<_OptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppColors.forestGreen : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppColors.forestGreen
                  : AppColors.sageGreen.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isSelected
                    ? AppColors.forestGreen.withOpacity(0.3)
                    : AppColors.darkGreen.withOpacity(0.05),
                blurRadius: widget.isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Letter badge
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Colors.white
                      : AppColors.sageGreen.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.letter.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: widget.isSelected
                          ? AppColors.forestGreen
                          : AppColors.darkGreen,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Option text
              Expanded(
                child: Text(
                  widget.text,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isSelected
                        ? Colors.white
                        : AppColors.darkGreen,
                    height: 1.4,
                  ),
                ),
              ),
              // Checkmark
              if (widget.isSelected)
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isSelected ? 1.0 : 0.0,
                  child: Container(
                    margin: const EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
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
