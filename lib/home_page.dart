import 'package:flutter/material.dart';
import 'noti_service.dart'; // Import the dedicated service file


// Instantiate the service for use in the UI
final NotiService notiService = NotiService();


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  // Helper for in-app confirmation (uses SnackBar)
  void _showInAppMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Notification Planner'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- 1. Button to show notification now ---
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications_active),
              onPressed: () {
                notiService.showNotification(
                  title: "Daily Affirmation",
                  body: "You're a great developer! Keep up the streak!",
                );
                _showInAppMessage(context, "Immediate Notification Sent!", Colors.green);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12), backgroundColor: Colors.green),
              label: const Text("Send Noti Now", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 30),
           
            // --- 2. Button to schedule notification for later ---
            ElevatedButton.icon(
              icon: const Icon(Icons.schedule),
              onPressed: () {
                notiService.scheduleNotification(
                  title: "Code Reminder (Daily)",
                  body: "Time for your evening coding session! Secure your XP.",
                  hour: 23, // 11 PM local time
                  minute: 0,
                );
                _showInAppMessage(context, "Daily Reminder Scheduled for 11:00 PM!", Colors.indigo);
              },
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12), backgroundColor: Colors.indigo),
              label: const Text("Schedule Noti (11 PM)", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
             const SizedBox(height: 30),


            // --- 3. Button to cancel all notifications ---
            TextButton.icon(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                notiService.cancelAllNotifications();
                _showInAppMessage(context, "All scheduled reminders cancelled!", Colors.red);
              },
              label: const Text("Cancel All Notifications", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}