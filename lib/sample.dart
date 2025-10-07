import 'package:flutter/material.dart';

// --- Global State Simulation (In a real app, this would use SharedPreferences or a database) ---
class AppDevState {
  static int daysInStreak = 0;
  static int featuresCompleted = 0;
  static double currentXP = 0.0; // Stored as a ratio (0.0 to 1.0)
  static int developerLevel = 1;
  static const double XP_CAP = 100.0;
  static const double XP_PER_TASK = 20.0; // 20% progress per task

  // Method to reset all progress to initial values
  static void reset() {
    daysInStreak = 0; // Reset to 0, the _updateStreakAndAffirmation will increment it to 1 for the 'new' first day.
    featuresCompleted = 0;
    currentXP = 0.0;
    developerLevel = 1;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dev Daily Boost',
      home: DailyDevAffirmation(),
    );
  }
}

// -------------------------------------------------------------------
// --- The Daily Affirmation Widget ---
// -------------------------------------------------------------------
class DailyDevAffirmation extends StatefulWidget {
  const DailyDevAffirmation({super.key});

  @override
  State<DailyDevAffirmation> createState() => _DailyDevAffirmationState();
}

class _DailyDevAffirmationState extends State<DailyDevAffirmation> {
  // We'll call this once when the widget is created, simulating a daily check-in.
  @override
  void initState() {
    super.initState();
    _updateStreakAndAffirmation();
  }

  void _updateStreakAndAffirmation() {
    setState(() {
      // 1. Simulate Daily Streak Check
      AppDevState.daysInStreak += 1;

      // 2. Clear XP bar if a new day starts (You start a new XP goal each day)
      // This is optional and depends on how you want to track progress.
      // AppDevState.currentXP = 0.0;
    });
  }

  void _taskCompleted() {
    setState(() {
      AppDevState.featuresCompleted++;
      AppDevState.currentXP += (AppDevState.XP_PER_TASK / AppDevState.XP_CAP); // Add 20% progress

      // Check for Level Up!
      if (AppDevState.currentXP >= 1.0) {
        AppDevState.developerLevel++;
        AppDevState.currentXP = 0.0; // Reset XP for the next level
        _showLevelUpDialog();
      }
    });
  }

  void _showLevelUpDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🌟 LEVEL UP! 🌟'),
          content: Text(
            'Incredible work, Developer! You have reached *Level ${AppDevState.developerLevel}* of Mastery! Keep shipping those features!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('ACKNOWLEDGE'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRestartConfirmationDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Reset All Progress?'),
          content: const Text(
            'Are you sure you want to restart your development journey? All progress (streak, features, XP, level) will be reset.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('RESET'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Close the dialog
                _restartApp(); // Perform the actual reset
              },
            ),
          ],
        );
      },
    );
  }

  void _restartApp() {
    setState(() {
      AppDevState.reset();
      // After resetting, simulate the start of a new day's streak
      // by explicitly calling the streak update logic.
      AppDevState.daysInStreak += 1;
    });
  }

  String _getAffirmation() {
    if (AppDevState.daysInStreak >= 7) {
      return "Code Hero! Your *${AppDevState.daysInStreak} day streak* proves your discipline. You are not blocked, you are simply preparing for your next great commit.";
    } else if (AppDevState.daysInStreak >= 3) {
      return "Solid work! Today, *debug with curiosity*, not frustration. Every error message is a clue leading you to the solution.";
    } else {
      return "Welcome back! Start with the smallest ticket. *Progress over perfection.* You have the skills to build the incredible.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DAILY DEV BOOST'),
        backgroundColor: Colors.green.shade700,
        actions: <Widget>[
          // Duolingo-style Streak Icon
          Row(
            children: <Widget>[
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 28),
              const SizedBox(width: 4),
              Text(
                '${AppDevState.daysInStreak}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
              ),
              const SizedBox(width: 16),
            ],
          ),
          // Restart Button
          IconButton(
            icon: const Icon(Icons.restart_alt, color: Colors.white),
            tooltip: 'Restart Progress',
            onPressed: _showRestartConfirmationDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // --- Developer Owl Message ---
            _buildAffirmationCard(context),

            const SizedBox(height: 24),

            // --- Level Progress Bar (Duolingo Style) ---
            Text(
              'LEVEL ${AppDevState.developerLevel} PROGRESS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: AppDevState.currentXP, // Value from 0.0 to 1.0
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'XP: ${(AppDevState.currentXP * AppDevState.XP_CAP).round()}/${AppDevState.XP_CAP.round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),

            const Divider(height: 30),

            // --- Features Shipped Metric ---
            _buildMetricTile(
              icon: Icons.check_circle_outline,
              label: 'Features Shipped',
              value: '${AppDevState.featuresCompleted}',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMetricTile(
              icon: Icons.code,
              label: 'Commits Today (XP Earning Potential)',
              value: '${((1.0 - AppDevState.currentXP) * AppDevState.XP_CAP).round()} XP Left',
              color: Colors.purple,
            ),
            const SizedBox(height: 40),

            // --- Call to Action Button ---
            ElevatedButton(
              onPressed: AppDevState.currentXP < 1.0 ? _taskCompleted : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppDevState.currentXP < 1.0 ? Colors.green.shade500 : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                AppDevState.currentXP < 1.0
                    ? 'COMPLETE TASK & EARN ${AppDevState.XP_PER_TASK.round()} XP'
                    : 'LEVEL UP GOAL COMPLETE!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the main affirmation card
  Widget _buildAffirmationCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Image.network(
              'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg', // Placeholder image URL
              height: 60,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
                  const Icon(Icons.rocket_launch, size: 60, color: Colors.teal),
            ),
            const SizedBox(height: 12),
            Text(
              'Your Daily Dev Message:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getAffirmation(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build progress metric tiles
  Widget _buildMetricTile({required IconData icon, required String label, required String value, required Color color}) {
    return Row(
      children: <Widget>[
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    );
  }
}
