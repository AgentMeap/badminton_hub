import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    // Android doc cau hinh tu android/app/google-services.json.
    await Firebase.initializeApp();
  } catch (e) {
    // Nen tang chua cau hinh Firebase (iOS/web/desktop): app van chay, chi tat Google Sign-In.
    debugPrint('Firebase chua duoc khoi tao: $e');
  }
  runApp(const BadmintonApp());
}
