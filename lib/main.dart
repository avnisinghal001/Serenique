import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:workmanager/workmanager.dart'; // Import workmanager
import 'package:serenique/services/notification_service.dart'; // Import our service
import 'firebase_options.dart';
import 'widgets/auth_wrapper.dart';
import 'utils/app_colors.dart';
import 'screens/email_verification_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/main_navigation_screen.dart';

// --- THIS IS THE BACKGROUND TASK HANDLER ---
// This function needs to be outside of any class
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Initialize the notification service for the background task
    await NotificationService.instance.init();
    // Show the notification from the background
    await NotificationService.instance.showAffirmationNotification();
    return Future.value(true);
  });
}
// -----------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize our notification service for the main app
  await NotificationService.instance.init();
  
  // Initialize the workmanager
  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true, // Set to false for production
  );
  
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serenique',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.lightBeige,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: AppColors.darkGreen,
                displayColor: AppColors.darkGreen,
              ),
        ),
      ),
      home: const AuthWrapper(),
      routes: {
        '/email-verification': (context) => const EmailVerificationScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/quiz': (context) => const QuizScreen(),
        '/dashboard': (context) => const MainNavigationScreen(),
      },
    );
  }
}