import 'package:flutter/material.dart';
import 'main/app.dart';
import 'main/global.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();
  await Firebase.initializeApp();

  runApp(const MyApp());
}
