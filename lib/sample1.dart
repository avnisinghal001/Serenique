import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Required for Timer

// --- Global State Management using ChangeNotifier and Provider ---
class AppDevData extends ChangeNotifier {
  int _daysInStreak;
  int _featuresCompleted;
  double _currentXP; // Stored as a ratio (0.0 to 1.0)
  int _developerLevel;
  DateTime? _cooldownEndsAt; // Renamed to be explicit about cooldown end time
  int _tasksUntilCooldownStarts; // New: counts tasks until the cooldown activates
  Timer? _cooldownTimer; // New: To update cooldown UI

  static const double XP_CAP = 100.0;
  static const double XP_PER_TASK = 20.0; // 20% progress per task
  static const Duration TASK_COOLDOWN_DURATION = Duration(hours: 24); // 24-hour cooldown
  static const int TASKS_PER_COOLDOWN_CYCLE = 5; // New: Number of tasks before cooldown starts

  // Initialize all properties in the initializer list
  AppDevData()
      : _daysInStreak = 0,
        _featuresCompleted = 0,
        _currentXP = 0.0,
        _developerLevel = 1,
        _cooldownEndsAt = null,
        _tasksUntilCooldownStarts = TASKS_PER_COOLDOWN_CYCLE {
    _startCooldownTimerIfNeeded();
  }

  // Getters for UI access
  int get daysInStreak => _daysInStreak;
  int get featuresCompleted => _featuresCompleted;
  double get currentXP => _currentXP;
  int get developerLevel => _developerLevel;
  DateTime? get cooldownEndsAt => _cooldownEndsAt;
  int get tasksUntilCooldownStarts => _tasksUntilCooldownStarts;

  // Determines if a task can be completed based on the 5-task limit and cooldown
  bool get canCompleteTask {
    if (_tasksUntilCooldownStarts > 0) {
      return true; // Still have tasks to complete before hitting cooldown threshold
    }
    // If _tasksUntilCooldownStarts is 0, we are in the cooldown phase
    if (_cooldownEndsAt == null) {
      // This case should ideally not be reachable if logic is consistent
      // If tasks count reaches 0, _cooldownEndsAt should be set.
      return true;
    }
    return DateTime.now().isAfter(_cooldownEndsAt!);
  }

  // Calculates remaining cooldown duration
  Duration get remainingCooldown {
    if (_tasksUntilCooldownStarts > 0 || _cooldownEndsAt == null) {
      return Duration.zero; // No cooldown active or pending, or tasks still available
    }
    final now = DateTime.now();
    if (now.isBefore(_cooldownEndsAt!)) {
      return _cooldownEndsAt!.difference(now);
    }
    return Duration.zero; // Cooldown has expired
  }

  // Starts a periodic timer to update the UI during cooldown
  void _startCooldownTimerIfNeeded() {
    // Only start if cooldown is active, not already running, and cooldownEndsAt is set
    if (_tasksUntilCooldownStarts == 0 &&
        _cooldownEndsAt != null &&
        DateTime.now().isBefore(_cooldownEndsAt!) &&
        _cooldownTimer == null) {
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (DateTime.now().isAfter(_cooldownEndsAt!)) {
          // Cooldown has expired
          _stopCooldownTimer();
          _cooldownEndsAt = null; // Clear the cooldown end time
          _tasksUntilCooldownStarts = TASKS_PER_COOLDOWN_CYCLE; // Reset tasks for next cycle
        }
        notifyListeners(); // Update UI with new cooldown time or when it expires
      });
    }
  }

  // Stops the cooldown timer
  void _stopCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  @override
  void dispose() {
    _stopCooldownTimer(); // Clean up timer when the provider is disposed
    super.dispose();
  }

  // Simulates a daily check-in, increments streak
  void updateStreakAndAffirmation() {
    _daysInStreak += 1;
    notifyListeners();
  }

  // Handles task completion logic
  int taskCompleted() {
    if (!canCompleteTask) return _developerLevel; // Should not be called if button is disabled

    _featuresCompleted++;
    _currentXP += (XP_PER_TASK / XP_CAP);

    _tasksUntilCooldownStarts--; // Decrement the count of tasks remaining until cooldown

    if (_tasksUntilCooldownStarts == 0) {
      // The threshold of TASKS_PER_COOLDOWN_CYCLE has been met, now start the cooldown.
      _cooldownEndsAt = DateTime.now().add(TASK_COOLDOWN_DURATION);
      _startCooldownTimerIfNeeded(); // Ensure timer starts if cooldown is now active
    }

    int oldLevel = _developerLevel;
    // Check for Level Up!
    if (_currentXP >= 1.0) {
      _developerLevel++;
      _currentXP = 0.0; // Reset XP for the next level
    }

    notifyListeners();
    return oldLevel; // Return the level *before* potential increment for UI dialog logic
  }

  // Resets all progress
  void reset() {
    _daysInStreak = 0;
    _featuresCompleted = 0;
    _currentXP = 0.0;
    _developerLevel = 1;
    _cooldownEndsAt = null; // Reset cooldown
    _tasksUntilCooldownStarts = TASKS_PER_COOLDOWN_CYCLE; // Reset tasks until next cooldown
    _stopCooldownTimer(); // Ensure timer is stopped if reset occurs
    notifyListeners();
  }

  // Provides daily affirmation messages
  String getAffirmation() {
    if (_daysInStreak >= 7) {
      return "Code Hero! Your *$_daysInStreak day streak* proves your discipline. You are not blocked, you are simply preparing for your next great commit.";
    } else if (_daysInStreak >= 3) {
      return "Solid work! Today, *debug with curiosity*, not frustration. Every error message is a clue leading you to the solution.";
    } else {
      return "Welcome back! Start with the smallest ticket. *Progress over perfection.* You have the skills to build the incredible.";
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppDevData>(
      create: (BuildContext context) => AppDevData(),
      builder: (BuildContext context, Widget? child) {
        return const MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dev Daily Boost',
          home: DailyDevAffirmation(),
        );
      },
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
    // Use Future.microtask to ensure the provider is available in the context
    // before attempting to read from it in initState.
    Future.microtask(() {
      context.read<AppDevData>().updateStreakAndAffirmation();
    });
  }

  void _taskCompleted() {
    final appDevData = context.read<AppDevData>();
    final int previousLevel = appDevData.developerLevel;
    appDevData.taskCompleted();

    // Check for level up after state update
    if (appDevData.developerLevel > previousLevel) {
      // Use Future.microtask to ensure the UI has a chance to rebuild
      // with the new level before showing the dialog.
      Future.microtask(() => _showLevelUpDialog(appDevData.developerLevel));
    }
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('🌟 LEVEL UP! 🌟'),
          content: Text(
            'Incredible work, Developer! You have reached *Level $newLevel* of Mastery! Keep shipping those features!',
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
    context.read<AppDevData>().reset();
    // After resetting, simulate the start of a new day's streak
    // by explicitly calling the streak update logic.
    context.read<AppDevData>().updateStreakAndAffirmation();
  }

  // Helper method to format Duration into HH:MM:SS string
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final AppDevData appDevData = context.watch<AppDevData>();
    final bool levelGoalComplete = appDevData.currentXP >= 1.0;
    final bool buttonDisabled = levelGoalComplete || !appDevData.canCompleteTask;

    String buttonText;
    if (levelGoalComplete) {
      buttonText = 'LEVEL UP GOAL COMPLETE!';
    } else if (appDevData.tasksUntilCooldownStarts > 0) {
      buttonText = 'COMPLETE TASK (${appDevData.tasksUntilCooldownStarts} left) & EARN ${AppDevData.XP_PER_TASK.round()} XP';
    } else { // Cooldown is active
      final Duration remaining = appDevData.remainingCooldown;
      buttonText = 'NEXT TASK IN ${_formatDuration(remaining)}';
    }

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
                '${appDevData.daysInStreak}',
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
            _buildAffirmationCard(context, appDevData.getAffirmation()),

            const SizedBox(height: 24),

            // --- Level Progress Bar (Duolingo Style) ---
            Text(
              'LEVEL ${appDevData.developerLevel} PROGRESS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: appDevData.currentXP, // Value from 0.0 to 1.0
              minHeight: 12,
              borderRadius: BorderRadius.circular(6),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'XP: ${(appDevData.currentXP * AppDevData.XP_CAP).round()}/${AppDevData.XP_CAP.round()}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),

            const Divider(height: 30),

            // --- Features Shipped Metric ---
            _buildMetricTile(
              icon: Icons.check_circle_outline,
              label: 'Features Shipped',
              value: '${appDevData.featuresCompleted}',
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            _buildMetricTile(
              icon: Icons.code,
              label: 'Commits Today (XP Earning Potential)',
              value: '${((1.0 - appDevData.currentXP) * AppDevData.XP_CAP).round()} XP Left',
              color: Colors.purple,
            ),
            const SizedBox(height: 40),

            // --- Call to Action Button ---
            ElevatedButton(
              onPressed: buttonDisabled ? null : _taskCompleted,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: buttonDisabled ? Colors.grey : Colors.green.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build the main affirmation card
  Widget _buildAffirmationCard(BuildContext context, String affirmationText) {
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
              affirmationText,
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