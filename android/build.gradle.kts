plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied last.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.serenique_fresh_start"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.example.serenique_fresh_start"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// This section is required by Flutter.
flutter {
    source = "../.."
}

dependencies {
    // You can add your Android-specific dependencies here if needed.
    // For example: implementation("androidx.work:work-runtime-ktx:2.9.0")
}