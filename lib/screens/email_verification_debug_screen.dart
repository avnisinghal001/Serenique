import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class EmailVerificationDebugScreen extends StatefulWidget {
  const EmailVerificationDebugScreen({super.key});

  @override
  State<EmailVerificationDebugScreen> createState() =>
      _EmailVerificationDebugScreenState();
}

class _EmailVerificationDebugScreenState
    extends State<EmailVerificationDebugScreen> {
  final AuthService _authService = AuthService();
  String _debugInfo = '';

  @override
  void initState() {
    super.initState();
    _gatherDebugInfo();
  }

  void _gatherDebugInfo() {
    final user = _authService.currentUser;
    setState(() {
      _debugInfo =
          '''
Debug Information:
==================
User Email: ${user?.email ?? 'No user'}
Email Verified: ${user?.emailVerified ?? false}
User ID: ${user?.uid ?? 'N/A'}
Display Name: ${user?.displayName ?? 'N/A'}

Check:
1. Firebase Console → Authentication → Sign-in method → Email/Password is ENABLED
2. Firebase Console → Authentication → Templates → Email verification is ENABLED
3. Check spam folder for: noreply@serenique-avni.firebaseapp.com
4. Firebase may have rate limited your requests
''';
    });
  }

  Future<void> _sendTestEmail() async {
    try {
      await _authService.sendVerificationEmail();
      setState(() {
        _debugInfo += '\n✅ Email send request successful at ${DateTime.now()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Test email sent! Check your inbox and spam folder.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _debugInfo += '\n❌ Error: $e';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification Debug'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _debugInfo,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _sendTestEmail,
                child: const Text('Send Test Verification Email'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _gatherDebugInfo,
                child: const Text('Refresh Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
