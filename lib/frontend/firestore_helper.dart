import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';

Future<void> signUpAndSaveUser({
  required BuildContext context,
  required String firstName,
  required String lastName,
  required String email,
  required String password,
  required String age,
  required String gender,
}) async {
  try {
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception("לא נוצר משתמש.");
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'userId': user.uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password, // אל תשאירי את זה בפרודקשן!
      'age': int.tryParse(age),
      'gender': gender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  } on FirebaseAuthException catch (e) {
    String message;
    if (e.code == 'email-already-in-use') {
      message = 'האימייל כבר בשימוש.';
    } else if (e.code == 'weak-password') {
      message = 'הסיסמה חלשה מדי.';
    } else {
      message = 'שגיאה בהרשמה: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('שגיאה כללית: $e')));
  }
}
