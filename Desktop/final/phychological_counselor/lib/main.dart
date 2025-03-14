import 'package:flutter/material.dart';
import 'main/app.dart';
import 'main/global.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Global.init();

  runApp(const MyApp());
}
