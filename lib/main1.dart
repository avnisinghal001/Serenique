import 'package:flutter/material.dart';
// Imports the necessary service and the UI page
import 'noti_service.dart';
import 'home_page.dart';


void main() async {
  // Ensures Flutter framework is ready before running plugins
  WidgetsFlutterBinding.ensureInitialized();


  // Initialize the notification service asynchronously
  await NotiService().initNotification();


  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Local Notification Demo',
      home: HomePage(), // Launch the HomePage UI
    );
  }
}