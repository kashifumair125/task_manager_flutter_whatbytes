// File generated using Firebase CLI
// Run: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAt4nSLLZASlyUZN57XRjS7k_S-6DqYzEc',
    appId: '1:370194898940:web:your-web-app-id',
    messagingSenderId: '370194898940',
    projectId: 'task-manager-253d2',
    authDomain: 'task-manager-253d2.firebaseapp.com',
    storageBucket: 'task-manager-253d2.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAt4nSLLZASlyUZN57XRjS7k_S-6DqYzEc',
    appId: '1:370194898940:android:285ddd1a2fc3adb25f5c79',
    messagingSenderId: '370194898940',
    projectId: 'task-manager-253d2',
    storageBucket: 'task-manager-253d2.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAt4nSLLZASlyUZN57XRjS7k_S-6DqYzEc',
    appId: '1:370194898940:ios:your-ios-app-id',
    messagingSenderId: '370194898940',
    projectId: 'task-manager-253d2',
    storageBucket: 'task-manager-253d2.firebasestorage.app',
    iosBundleId: 'com.example.taskManagerApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAt4nSLLZASlyUZN57XRjS7k_S-6DqYzEc',
    appId: '1:370194898940:macos:your-macos-app-id',
    messagingSenderId: '370194898940',
    projectId: 'task-manager-253d2',
    storageBucket: 'task-manager-253d2.firebasestorage.app',
    iosBundleId: 'com.example.taskManagerApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAt4nSLLZASlyUZN57XRjS7k_S-6DqYzEc',
    appId: '1:370194898940:windows:your-windows-app-id',
    messagingSenderId: '370194898940',
    projectId: 'task-manager-253d2',
    storageBucket: 'task-manager-253d2.firebasestorage.app',
  );
}

