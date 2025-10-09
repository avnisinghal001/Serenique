import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth =
      FirebaseAuth.instance; //underscore means only this class can access it
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Reload current user to get updated verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Send verification email with rate limiting
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      if (e.toString().contains('too-many-requests')) {
        throw 'Too many email requests. Please wait a few minutes before trying again.';
      } else {
        throw e.toString();
      }
    }
  }

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    int age,
    String gender,
    String profession,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(fullName);

      // Send email verification with delay to avoid rate limiting
      try {
        await result.user?.sendEmailVerification();
        print('Verification email sent to: ${result.user?.email}');
      } catch (emailError) {
        print(
          'Warning: Could not send verification email immediately: $emailError',
        );
        // Don't throw error here, let user resend manually if needed
      }

      // Create user document in Firestore with all details
      await _createUserDocument(result.user!, fullName, age, gender, profession);

      return {'success': true, 'message': 'Registration successful'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _handleAuthException(e)};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // Create user document in Firestore
  Future<void> _createUserDocument(
    User user,
    String fullName,
    int age,
    String gender,
    String profession,
  ) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'fullName': fullName,
      'age': age,
      'gender': gender,
      'profession': profession,
      'createdAt': FieldValue.serverTimestamp(),
      'quizCompleted': false, // Track if user completed onboarding quiz
    });
  }

  // Save quiz responses to Firestore
  Future<void> saveQuizResponses(Map<int, String> responses) async {
    final user = _auth.currentUser;
    if (user == null) throw 'No user logged in';

    // Convert responses map to List for Firestore
    final responsesList = responses.entries
        .map((entry) => {
              'questionId': entry.key,
              'answer': entry.value,
            })
        .toList();

    await _firestore.collection('users').doc(user.uid).update({
      'quizResponses': responsesList,
      'quizCompleted': true,
      'quizCompletedAt': FieldValue.serverTimestamp(),
    });
  }

  // Check if user has completed the quiz
  Future<bool> hasCompletedQuiz() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data()?['quizCompleted'] ?? false;
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('Password reset email sent to: $email');
    } on FirebaseAuthException catch (e) {
      print('Error sending password reset email: ${e.code}');
      if (e.code == 'too-many-requests') {
        throw 'Too many requests. Please wait a few minutes before trying again.';
      }
      throw _handleAuthException(e);
    } catch (e) {
      print('Unexpected error sending password reset: $e');
      throw 'Failed to send password reset email. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'The password is too weak.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
