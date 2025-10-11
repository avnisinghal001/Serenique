import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<String> affirmations = [
    "You are capable of amazing things.",
    "Your potential is limitless.",
    "You are deserving of happiness and success.",
    "Every day is a new opportunity to grow.",
    "You radiate positivity and light.",
    "Believe in yourself and all that you are.",
    "You are strong, resilient, and brave."
  ];

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  String _getRandomAffirmation() {
    final random = Random();
    return affirmations[random.nextInt(affirmations.length)];
  }

  // This is the simple, one-time notification method that our background task will call.
  Future<void> showAffirmationNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'affirmation_channel',
      'Affirmations',
      channelDescription: 'Channel for positive affirmations',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'A positive thought for you',
      _getRandomAffirmation(),
      platformDetails,
    );
  }
}