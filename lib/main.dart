import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - this must complete before the app runs
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
    
    // Verify Firebase is actually initialized
    if (Firebase.apps.isEmpty) {
      throw Exception('Firebase initialization completed but no apps were created.');
    }
  } catch (e, stackTrace) {
    // Log the error with full stack trace for debugging
    debugPrint('Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Re-throw to prevent app from running without Firebase
    rethrow;
  }
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
