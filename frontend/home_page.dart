import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:phychological_counselor/home/screens/home_screen.dart'; // היבוא של home_screen.dart
import 'package:phychological_counselor/frontend/SignUpPage.dart';  // היבוא של SignUpPage
//import 'package:phychological_counselor/frontend/profile_page.dart';
import 'package:phychological_counselor/main/navigation/routes/name.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:phychological_counselor/frontend/reset_password_page.dart';
import 'package:phychological_counselor/frontend/reset_password_page.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
  FocusScope.of(context).unfocus(); // סגור מקלדת

   final email = _emailController.text.trim();
  final password = _passwordController.text.trim();
  print("📧 Email: '$email'");
  print("🔑 Password: '$password'");

  if (email.isEmpty || password.isEmpty) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Missing Info'),
        content: Text('Please fill in both fields'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
    return;
  }
    print("Trying login with email: $email");


// <<<<<<< HEAD
//   try {
//         print("Running Firestore query...");

//     final userDoc = await FirebaseFirestore.instance
//         .collection('users')
//         .where('email', isEqualTo: email)
//         .get();
//          print("Query complete");
//     print("Number of users found: ${userDoc.docs.length}");


//   if (userDoc.docs.isEmpty) {
//   showDialog(
//     context: context,
//     builder: (_) => AlertDialog(
//       title: Text('User Not Found'),
//       content: Text('No user found with this email'),
// =======
 try {
  final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  print("✅ Logged in with FirebaseAuth, UID: ${credential.user?.uid}");

  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);

} on FirebaseAuthException catch (e) {
    print("❌ FirebaseAuth Login Error: $e");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Login Failed'),
        content: Text('Error: ${e.message}'),

        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
// <<<<<<< HEAD
//   return;
// }

//     final userData = userDoc.docs.first.data();
//         print("User data from Firestore: $userData");

//     if (userData['password'] == password) {
//       // הצלחה → מעבר לצ'אט
//       Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
//     } else {
//       throw Exception('Incorrect password');
//     }
//   } catch (e) {
// =======
  }catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Login Failed'),
          content: Text('Error: $e'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        ),
      );
  }
}
Future<void> manualLoginTest() async {
  final email = _emailController.text.trim();
  final password = _passwordController.text.trim();

  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    print("✅ התחברות הצליחה! UID: ${credential.user?.uid}");
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
  } on FirebaseAuthException catch (e) {
    print("❌ שגיאה: ${e.message}");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Login Failed"),
        content: Text("שגיאה: ${e.message}"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("סגור")),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
  backgroundColor: Colors.white, // ← הוסיפי שורה זו

      appBar: AppBar(
  backgroundColor: Colors.white,     // צבע רקע לבן
  elevation: 0,                      // אין צל בכלל
  centerTitle: true,                // אם את רוצה ליישר את הכותרת למרכז
  iconTheme: IconThemeData(color: Colors.black), // ← צבע חץ אחורה (אם יש)
  title: Text(
    '', // השאירי ריק או כתבי 'Welcome' אם צריך
    style: TextStyle(
      color: Colors.indigo.shade400,
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
),

      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Welcome',
                  style: TextStyle(
                    color: Colors.indigo.shade400,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                MouseRegion(
                  onEnter: (event) => {},
                  onExit: (event) => {},
                  child: Container(
                    width: 250,
                      height: 45, // ✅ חדש: גובה קטן יותר
                    child: TextField(
                      style: TextStyle(color: Colors.black,  fontSize: 13),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.indigo.shade400,  fontSize: 14),// או אפילו 12 אם את רוצה קטן יו),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                MouseRegion(
                  onEnter: (event) => {},
                  onExit: (event) => {},
                  child: Container(
                    width: 250,
                      height: 45, // ✅ חדש: גובה קטן יותר

                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.indigo.shade400 , fontSize: 14 // או אפילו 12 אם את רוצה קטן יותר
),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.indigo.shade400),
                        ),
                      ),
                      obscureText: true,
                    ),
                  ),
                ),
                // כפתור Login
                
 Container(
  width: 300, // אותו רוחב כמו תיבות הטקסט
  alignment: Alignment.centerRight, // יישור פנימי לימין
  child: TextButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResetPasswordPage()),
      );
    },
    child: Text(
      'Forgot your password?',
      style: TextStyle(
        color: Colors.indigo.shade400,
        fontSize: 14,
      ),
    ),
  ),
),

SizedBox(
  width: 70,
  height: 30,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo.shade400,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
            padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

    ),
    onPressed: _login,
    child: Text('Login', style: TextStyle(fontSize: 18)),
  ),
),
SizedBox(height: 10), // ← מוסיף רווח אנכי של 10 פיקסלים

//ElevatedButton(
//   onPressed: manualLoginTest,
//   child: Text('🔍 בדוק התחברות ידנית'),
// ),



             // כפתור Sign Up
SizedBox(
  width: 70,
  height: 30,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.indigo.shade400,
      foregroundColor: Colors.white,
      shape: StadiumBorder(),
            padding: EdgeInsets.zero, // ✅ מבטל מרווחים פנימיים נוספים

    ),
    onPressed: () {
      FocusScope.of(context).unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignUpPage()),
      );
    },
    child: Text('Sign Up', style: TextStyle(fontSize: 18)),
  ),
),

              ],
            ),
          ),
        ),
      ),
    );
  }

}
 