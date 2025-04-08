import 'package:flutter/material.dart';
import 'main/app.dart';
import 'main/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 📌 ודא שהייבוא הזה קיים
import 'ai_chat/provider/chat_provider.dart';
import 'main/app.dart';
import 'main/global.dart';
import 'frontend/firebase_initializer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//import 'frontend/therapy_bot_page.dart';
//import 'package:phychological_counselor/frontend/therapy_bot_page.dart'; // הייבוא של TherapyBotPage


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await FirebaseInitializer.initialize(); // ← זה מחליף את Firebase.initializeApp

  await Global.init();

  testFirestoreAccess(); // ← בדיקת חיבור ל-Firestore

  runApp(const MyApp());
}
void testFirestoreAccess() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    print("✅ Success! Got ${snapshot.docs.length} documents from Firestore.");
  } catch (e) {
    print("❌ Firestore access failed: $e");
  }
}