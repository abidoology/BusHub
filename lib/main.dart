// Main entry point of the Dhaka Bus Route & Fare App
// This app helps people find buses, routes, and fares in Dhaka city

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';

// Main function - initializes Firebase and starts the app
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    // Web: Firebase is initialized in index.html
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBHzJzFF9FrCy5ywJqE37rKUfrbSKj1xrw",
        authDomain: "dhaka-route-and-fare.firebaseapp.com",
        projectId: "dhaka-route-and-fare",
        storageBucket: "dhaka-route-and-fare.firebasestorage.app",
        messagingSenderId: "1008390294160",
        appId: "1:1008390294160:android:351df6f48c6b529026a615",
      ),
    );
  } else {
    // Mobile: Uses google-services.json (Android) or GoogleService-Info.plist (iOS)
    await Firebase.initializeApp();
  }

  // Run the app
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App title
      title: 'Dhaka Bus Route & Fare',

      // Remove debug banner
      debugShowCheckedModeBanner: false,

      // App theme
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,

        // Input decoration theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Starting screen - Home Screen
      home: const HomeScreen(),
    );
  }
}
