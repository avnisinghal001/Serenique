import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Serenique',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const SplashScreen(), // ✅ Start from splash screen
    );
  }
}

// ---------------------------- SPLASH SCREEN ----------------------------
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 40),

                // Logo and title
                Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 160,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'SERENIQUE',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shape your mind in a serene way',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                // Description + Buttons
                Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Your safe space for mind and soul.\nGuided meditations, mood tracking, and\ncommunity support — all in one app.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),

                    // Log in with email
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34C759),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Log in with email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Continue with Google
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        icon: Image.asset(
                          'assets/google_icon.png',
                          height: 22,
                        ),
                        label: Text(
                          'Continue with Google',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),

                // Footer text
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    'By continuing you are agreeing to our terms and condition',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------- LOGIN SCREEN ----------------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/logo.png', height: 120, width: 120),
                const SizedBox(height: 15),
                Text(
                  "SERENIQUE",
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  "Shape your mind in a serene way",
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "E-mail",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: "razvan@artone.studio",
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: "Enter your password",
                    prefixIcon: const Icon(Icons.vpn_key_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Forgot password?",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey[700],
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3AA76D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OnboardingScreen()),
                      );
                    },
                    child: Text(
                      "Log in",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("New here? ",
                        style: GoogleFonts.poppins(color: Colors.black87)),
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        "Create an account.",
                        style: GoogleFonts.poppins(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------- ONBOARDING SCREEN ----------------------------
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                "Welcome to serenique",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.brown[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                "✨ Welcome to Serenique ✨\nCollege life can get messy — deadlines, exams, and all the “figuring life out” stuff. Serenique is here to make things a little lighter. Think of it as your pocket space for mental well-being...",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              Image.asset('assets/mental_health.png', height: 250),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const StartScreen()),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_right_alt_rounded,
                          color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- START SCREEN ----------------------------
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _nameController = TextEditingController();

  void _startQuiz() {
    if (_nameController.text.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizScreen(index: 1, name: _nameController.text),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2F6D60),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white,
                child: Text('QUIZ',
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              const Text('Mental Health and Well-being',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: const Text('Start',
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------- QUIZ SCREEN ----------------------------
class QuizScreen extends StatefulWidget {
  final int index;
  final String name;

  const QuizScreen({super.key, required this.index, required this.name});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedOption;

  final List<Map<String, dynamic>> questions = [
    {
      "question": "How are you feeling today overall?",
      "options": ["Happy", "Okay", "Tired", "Sad"],
    },
    {
      "question": "How much energy do you have right now?",
      "options": ["Very low", "Low", "Moderate", "Very high"],
    },
    {
      "question": "How well did you sleep last night?",
      "options": ["Very poorly", "Poor", "Good", "Very Good"],
    },
    {
      "question": "How often have you felt stressed in the past few days?",
      "options": ["Never", "Rarely", "Sometimes", "Often"],
    },
    {
      "question": "Do you feel interested and motivated in your daily activities?",
      "options": ["Not at all", "A little", "Sometimes", "Mostly"],
    },
    {
      "question": "How often do you feel lonely or disconnected from others?",
      "options": ["Never", "Rarely", "Sometimes", "Always"],
    },
    {
      "question": "Do you feel you are able to handle challenges that come your way?",
      "options": ["Not at all", "A little", "Sometimes", "Mostly"],
    },
    {
      "question": "What would help you feel better right now?",
      "options": [
        "Talking to someone",
        "Relaxing/breathing",
        "Reading/learning",
        "Not sure"
      ],
    },
  ];

  void _goNext() {
    if (widget.index < questions.length) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizScreen(index: widget.index + 1, name: widget.name),
        ),
      );
    } else {
      _showFinishDialog();
    }
  }

  void _goPrevious() {
    if (widget.index > 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              QuizScreen(index: widget.index - 1, name: widget.name),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Quiz Completed!"),
        content: Text("Well done, ${widget.name}! 🎉"),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.popUntil(context, (route) => route.isFirst),
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionData = questions[widget.index - 1];
    final isLast = widget.index == questions.length;

    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          onPressed: _goPrevious,
          child:
              const Text("< Previous", style: TextStyle(color: Colors.white)),
        ),
        title: Text("${widget.index}/${questions.length}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Text(
                widget.index == questions.length ? "🎉" : "😊",
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              questionData["question"],
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ...List.generate(
              (questionData["options"] as List).length,
              (index) => RadioListTile(
                title: Text(questionData["options"][index]),
                value: index,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() => selectedOption = value);
                },
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: selectedOption != null
                  ? () {
                      if (isLast) {
                        _showFinishDialog();
                      } else {
                        _goNext();
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
              ),
              child: Text(
                isLast ? 'Finish' : 'Next',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}