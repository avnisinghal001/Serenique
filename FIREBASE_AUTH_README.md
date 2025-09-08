# Serenique - Firebase Authentication

A Flutter application with Firebase Authentication featuring sign-in, sign-up, password reset, and user management.

## Features

- ✅ Email/Password Authentication
- ✅ User Registration
- ✅ Password Reset
- ✅ User Profile Management
- ✅ Secure Authentication State Management
- ✅ Modern UI Design
- ✅ Cross-platform Support

## Screenshots

The app includes the following screens:
- **Sign In Screen**: Email/password login with validation
- **Sign Up Screen**: User registration with full name, email, and password
- **Forgot Password Screen**: Password reset functionality
- **Home Screen**: Welcome screen with user information and quick actions

## Setup Instructions

### 1. Firebase Project Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select an existing one
3. Enable Authentication:
   - Go to Authentication > Sign-in method
   - Enable "Email/Password" provider
4. Enable Firestore Database:
   - Go to Firestore Database
   - Create database in production mode
   - Set up security rules as needed

### 2. Platform Configuration

#### For Android:
1. In Firebase Console, add an Android app
2. Use package name: `com.example.serenique` (or your chosen package name)
3. Download `google-services.json`
4. Place it in `android/app/`

#### For iOS:
1. In Firebase Console, add an iOS app
2. Use bundle ID: `com.example.serenique` (or your chosen bundle ID)
3. Download `GoogleService-Info.plist`
4. Add it to your iOS project in Xcode

#### For Web:
1. In Firebase Console, add a Web app
2. Copy the configuration object

### 3. Configure Firebase Options

Update the `lib/firebase_options.dart` file with your actual Firebase configuration:

```dart
// Replace the placeholder values with your actual Firebase config
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
);
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── firebase_options.dart               # Firebase configuration
├── services/
│   └── auth_service.dart              # Authentication service
├── screens/
│   ├── sign_in_screen.dart            # Sign in UI
│   ├── sign_up_screen.dart            # Sign up UI
│   ├── forgot_password_screen.dart    # Password reset UI
│   └── home_screen.dart               # Home/dashboard UI
└── widgets/
    └── auth_wrapper.dart              # Authentication state wrapper
```

## Usage

### Authentication Service

The `AuthService` class handles all authentication operations:

```dart
final AuthService authService = AuthService();

// Sign in
await authService.signInWithEmailAndPassword(email, password);

// Sign up
await authService.registerWithEmailAndPassword(email, password, fullName);

// Reset password
await authService.resetPassword(email);

// Sign out
await authService.signOut();

// Get current user
User? user = authService.currentUser;

// Listen to auth state changes
authService.authStateChanges.listen((User? user) {
  // Handle auth state changes
});
```

### Navigation Flow

1. **App Launch**: `AuthWrapper` checks authentication state
2. **Not Authenticated**: Shows `SignInScreen`
3. **Authenticated**: Shows `HomeScreen`
4. **Sign Up**: Navigate from `SignInScreen` to `SignUpScreen`
5. **Forgot Password**: Navigate from `SignInScreen` to `ForgotPasswordScreen`

## Security Features

- Input validation on all forms
- Password visibility toggle
- Secure password requirements (minimum 6 characters)
- Email format validation
- Error handling for all authentication operations
- Automatic session management

## Customization

### Styling
- All screens use a consistent design system
- Easy to customize colors, fonts, and spacing
- Material Design 3 components

### Validation
- Custom form validators for email and password
- Real-time validation feedback
- User-friendly error messages

## Troubleshooting

### Common Issues

1. **"Target of URI doesn't exist" errors**: Run `flutter pub get` to install dependencies
2. **Firebase not configured**: Ensure `firebase_options.dart` has correct configuration
3. **Platform-specific issues**: Verify platform-specific Firebase setup (google-services.json, GoogleService-Info.plist)

### Firebase Rules

For Firestore, consider these basic security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Dependencies

- `firebase_core`: Firebase SDK core
- `firebase_auth`: Firebase Authentication
- `cloud_firestore`: Cloud Firestore database
- `flutter`: Flutter SDK

## License

This project is open source and available under the [MIT License](LICENSE).
