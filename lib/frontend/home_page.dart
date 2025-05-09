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
  
  final password = _passwordController.text;
  print("Trying to login with email: $email");

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        
  backgroundColor: Colors.black, // ← הוסיפי שורה זו

      appBar: AppBar(
        title: Text('', style: TextStyle(color: Colors.indigo.shade400)),
        backgroundColor: Colors.black,
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
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: TextStyle(color: Colors.indigo.shade400),
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
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(color: Colors.indigo.shade400),
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
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade400,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _login,
                  child: Text('Login'),
                ),

                TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResetPasswordPage()),
    );
  },
  child: Text(
    'Forgot your password?',
    style: TextStyle(color: Colors.indigo.shade400),
  ),
),

                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade400,
                    foregroundColor: Colors.white,
                  ),
              onPressed: () {
  FocusScope.of(context).unfocus(); // ← מוסיפים את זה לפני הניווט
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => SignUpPage()),
  );
},


                  child: Text('Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}
 