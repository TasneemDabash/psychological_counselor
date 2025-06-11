// // import 'package:flutter/material.dart';
// // import 'package:phychological_counselor/frontend/validation.dart';
// // import 'package:phychological_counselor/frontend/firestore_helper.dart';

// // class SignUpPage extends StatefulWidget {
// //   @override
// //   _SignUpPageState createState() => _SignUpPageState();
// // }

// // class _SignUpPageState extends State<SignUpPage> {
// //   final TextEditingController _firstNameController = TextEditingController();
// //   final TextEditingController _lastNameController = TextEditingController();
// //   final TextEditingController _emailController = TextEditingController();
// //   final TextEditingController _confirmEmailController = TextEditingController();
// //   final TextEditingController _ageController = TextEditingController();
// //   final TextEditingController _genderController = TextEditingController();
// //   final TextEditingController _passwordController = TextEditingController();
// //   final TextEditingController _confirmPasswordController = TextEditingController();

// //   bool _obscurePassword = true;
// //   bool _obscureConfirmPassword = true;

// //   void _signUp() async {
// //     final valid = validateStep(
// //       step: 0,
// //       context: context,
// //       firstNameController: _firstNameController,
// //       lastNameController: _lastNameController,
// //       emailController: _emailController,
// //       confirmEmailController: _confirmEmailController,
// //       ageController: _ageController,
// //       genderController: _genderController,
// //       passwordController: _passwordController,
// //       confirmPasswordController: _confirmPasswordController,
// //     );

// //     if (!valid) return;

// //     if (_emailController.text.trim() != _confirmEmailController.text.trim()) {
// // _showStyledError('Signup Error', 'Emails do not match.');
// //       return;
// //     }

// //     if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
// //       _showStyledError('Signup Error', 'Passwords do not match.');
// //       return;
// //     }

// //     await signUpAndSaveUser(
// //       context: context,
// //       firstName: _firstNameController.text.trim(),
// //       lastName: _lastNameController.text.trim(),
// //       email: _emailController.text.trim(),
// //       password: _passwordController.text.trim(),
// //       age: _ageController.text.trim(),
// //       gender: _genderController.text.trim(),
// //     );
// //   }

// //   void _showStyledError(String title, String message) {
// //   showDialog(
// //     context: context,
// //     builder: (_) => AlertDialog(
// //       backgroundColor: Colors.grey[200],
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //       title: Text(
// //         title,
// //         style: TextStyle(
// //           fontSize: 18,
// //           color: Colors.indigo.shade400,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       ),
// //       content: Text(
// //         message,
// //         style: TextStyle(fontSize: 16, color: Colors.black87),
// //       ),
// //       actions: [
// //         TextButton(
// //           onPressed: () => Navigator.pop(context),
// //           child: Text('OK', style: TextStyle(color: Colors.indigo.shade400)),
// //         ),
// //       ],
// //     ),
// //   );
// // }

// //   void _showInlineError(String message) {
// //   ScaffoldMessenger.of(context).showSnackBar(
// //     SnackBar(
// //       content: Text(message, style: const TextStyle(color: Colors.white)),
// //       backgroundColor: Colors.redAccent,
// //       behavior: SnackBarBehavior.floating,
// //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
// //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //       duration: const Duration(seconds: 3),
// //     ),
// //   );
// // }


// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         centerTitle: true,
// //         automaticallyImplyLeading: false,
// //         toolbarHeight: 160,
// //         title: Text(
// //           'Sign Up',
// //           style: TextStyle(
// //             color: Colors.indigo.shade400,
// //             fontSize: 50,
// //             fontWeight: FontWeight.bold,
// //           ),
// //         ),
// //       ),
// //       body: Center(
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.all(20),
// //           child: Card(
// //             color: Colors.white,
// //             elevation: 0,
// //             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //             child: Padding(
// //               padding: const EdgeInsets.all(24),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Row(
// //                     children: [
// //                       Expanded(child: _buildTextField(_firstNameController, 'First Name')),
// //                       const SizedBox(width: 10),
// //                       Expanded(child: _buildTextField(_lastNameController, 'Last Name')),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Row(
// //                     children: [
// //                       Expanded(child: _buildTextField(_emailController, 'Email')),
// //                       const SizedBox(width: 10),
// //                       Expanded(child: _buildTextField(_confirmEmailController, 'Confirm Email')),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Row(
// //                     children: [
// //                       Expanded(child: _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number)),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: Theme(
// //                           data: Theme.of(context).copyWith(
// //                             canvasColor: Colors.grey[200],
// //                             highlightColor: Colors.indigo.shade100,
// //                             splashColor: Colors.indigo.shade100,
// //                             hoverColor: Colors.indigo.shade100,
// //                           ),
// //                           child: DropdownButtonFormField<String>(
// //                             value: _genderController.text.isNotEmpty ? _genderController.text : null,
// //                             items: ['Male', 'Female', 'Other']
// //                                 .map((value) => DropdownMenuItem(
// //                                       value: value,
// //                                       child: Text(value, style: TextStyle(fontSize: 16, color: Colors.black)),
// //                                     ))
// //                                 .toList(),
// //                             onChanged: (value) => _genderController.text = value ?? '',
// //                             style: const TextStyle(fontSize: 16, color: Colors.black),
// //                             dropdownColor: Colors.grey[200],
// //                             iconEnabledColor: Colors.indigo.shade400,
// //                             decoration: InputDecoration(
// //                               labelText: 'Gender',
// //                               labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
// //                               floatingLabelStyle: TextStyle(fontSize: 14, color: Colors.indigo.shade400),
// //                               isDense: true,
// //                               contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
// //                               filled: true,
// //                               fillColor: Colors.white,
// //                               enabledBorder: OutlineInputBorder(
// //                                 borderSide: BorderSide(color: Colors.black, width: 1),
// //                               ),
// //                               focusedBorder: OutlineInputBorder(
// //                                 borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
// //                               ),
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 20),
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: _buildTextField(
// //                           _passwordController,
// //                           'Password',
// //                           obscure: _obscurePassword,
// //                           suffixIcon: IconButton(
// //                             icon: Icon(
// //                               _obscurePassword ? Icons.visibility_off : Icons.visibility,
// //                               color: Colors.grey,
// //                             ),
// //                             onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
// //                           ),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 10),
// //                       Expanded(
// //                         child: _buildTextField(
// //                           _confirmPasswordController,
// //                           'Confirm Password',
// //                           obscure: _obscureConfirmPassword,
// //                           suffixIcon: IconButton(
// //                             icon: Icon(
// //                               _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
// //                               color: Colors.grey,
// //                             ),
// //                             onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 30),
// //                   ElevatedButton(
// //                     onPressed: _signUp,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: Colors.indigo.shade400,
// //                       foregroundColor: Colors.white,
// //                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
// //                     ),
// //                     child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildTextField(
// //     TextEditingController controller,
// //     String label, {
// //     bool obscure = false,
// //     TextInputType keyboardType = TextInputType.text,
// //     Widget? suffixIcon,
// //   }) {
// //     return SizedBox(
// //       height: 50,
// //       child: TextField(
// //         controller: controller,
// //         obscureText: obscure,
// //         keyboardType: keyboardType,
// //         cursorColor: Colors.indigo.shade400,
// //         style: const TextStyle(fontSize: 16, color: Colors.black),
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: TextStyle(fontSize: 14, color: Colors.black),
// //           floatingLabelStyle: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
// //           isDense: true,
// //           contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
// //           filled: true,
// //           fillColor: Colors.white,
// //           suffixIcon: suffixIcon,
// //           enabledBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.black, width: 1),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'email_validator.dart';

// class SignUpPage extends StatefulWidget {
//   @override
//   _SignUpPageState createState() => _SignUpPageState();
// }

// class _SignUpPageState extends State<SignUpPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _obscurePassword = true;
//   bool _obscureConfirm = true;
//   String? _hoveredGender;

//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _confirmEmailController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _genderController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
// Future<void> _signUp() async {
//   if (!_formKey.currentState!.validate()) return;

//   final email    = _emailController.text.trim();
//   final password = _passwordController.text;

//   try {
//     // 1. יצירת המשתמש ב־Firebase Auth
//     UserCredential userCred = await FirebaseAuth.instance
//       .createUserWithEmailAndPassword(email: email, password: password);
//     final user = userCred.user!;

//     // 2. שליחת מייל אימות בלבד
//     await user.sendEmailVerification();
//  // 2. שמירה ב־Firestore
//     await FirebaseFirestore.instance
//       .collection('users')
//       .doc(user.uid)
//       .set({
//         'firstName': _firstNameController.text.trim(),
//         'lastName' : _lastNameController.text.trim(),
//         'email'    : email,
//         'password' : password,              // ⇦ כאן
//         'age'      : int.parse(_ageController.text),
//         'gender'   : _genderController.text,
//         'userId'   : user.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//           await user.sendEmailVerification();

//     // 3. משוב למשתמש
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text('נשלח מייל אימות ל־$email. בדקי את התיבה שלך.'),
//         backgroundColor: Colors.green,
//       ),
//     );

//     // 4. ניווט למסך VerifyEmail (אין שום עדכון Firestore פה!)
//     Navigator.pushReplacementNamed(context, '/verify-email');
//   }
//   on FirebaseAuthException catch (e) {
//     _showError(e.message!);
//   }
//   catch (e) {
//     _showError(e.toString());
//   }
// }

// //   Future<void> _signUp() async {
// //     if (!_formKey.currentState!.validate()) return;
    
// //   // נבדוק שהכתובת באמת “אמיתית” (deliverable) לפי ה־API
// //   final email = _emailController.text.trim();
  
// //  // bool emailIsReal = false;
//   // try {
//   //   emailIsReal = await isRealEmail(email);
//   // } catch (e) {
//   //   // אם יש תקלה ברשת או בהחזרת JSON, אפשר להציג הודעה ללקוח
//   //   _showError("Error validating email: ${e.toString()}");
//   //   return;
//   // }

//   // if (!emailIsReal) {
//   //   // אם הכתובת לא תקינה לפי הקריטריונים, נפסיק ונציג שגיאה
//   //   _showError("כתובת המייל לא תקינה או לא קיימת");
//   //   return;
//   // }

// //     try {
// //       UserCredential userCred = await FirebaseAuth.instance
// //           .createUserWithEmailAndPassword(
// //         email: _emailController.text.trim(),
// //         password: _passwordController.text,
// //       );

// //    //   String uid = userCred.user!.uid;
// //       final user = userCred.user!;

// //     // 2. שליחת מייל אימות לכתובת שהוזנה
// //     await user.sendEmailVerification();

// //     // 3. שמירת הנתונים ב־Firestore
// //     String uid = user.uid; 
// //       await FirebaseFirestore.instance.collection('users').doc(uid).set({
// //         'firstName': _firstNameController.text.trim(),
// //         'lastName': _lastNameController.text.trim(),
// //         'email': _emailController.text.trim(),
// //         'age': int.parse(_ageController.text),
// //         'gender': _genderController.text,
// //         'password': _passwordController.text,
// //         'userId': uid,
// //         'createdAt': FieldValue.serverTimestamp(),
// //       });
// //        ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('נשלח מייל אימות ל־$email. בדקי את התיבה שלך.'),
// //         backgroundColor: Colors.green,
// //       ),
// //     );
// //  Navigator.pushReplacementNamed(context, '/verify-email');
// //       return;
// //     }

// //     // 4. אם המייל מאומת, ממשיכים למסך הבית
// //     Navigator.pushReplacementNamed(context, '/home');
// //      // Navigator.pushReplacementNamed(context, '/home');
// //     } on FirebaseAuthException catch (e) {
// //       _showError(e.message!);
// //     } catch (e) {
// //       _showError(e.toString());
// //     }
// // //   }
// //  final password = _passwordController.text;

// //   try {
// //     // 1. יצירת משתמש ב־Authentication
// //     UserCredential userCred = await FirebaseAuth.instance
// //       .createUserWithEmailAndPassword(email: email, password: password);
// //     final user = userCred.user!;

// //     // 2. שמירת שדות המשתמש ב־Firestore
// //     String uid = user.uid;
// //     await FirebaseFirestore.instance
// //         .collection('users')
// //         .doc(uid)
// //         .set({
// //       'firstName': _firstNameController.text.trim(),
// //       'lastName':  _lastNameController.text.trim(),
// //       'email':     email,
// //       'age':       int.parse(_ageController.text),
// //       'gender':    _genderController.text,
// //       'password':  _passwordController.text,
// //       'userId':    uid,
// //       'createdAt': FieldValue.serverTimestamp(),
// //     });

// //     // 3. שליחת מייל אימות
// //     await user.sendEmailVerification();

// //     // 4. משוב למשתמש וניווט למסך אימות
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text('נשלח מייל אימות ל־$email. בדקי את התיבה שלך.'),
// //         backgroundColor: Colors.green,
// //       ),
// //     );
// //     Navigator.pushReplacementNamed(context, '/verify-email');
// //   }
// //   on FirebaseAuthException catch (e) {
// //     _showError(e.message!);
// //   }
// //   catch (e) {
// //     _showError(e.toString());
// //   }
// // }


//   void _showError(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), backgroundColor: Colors.red),
//     );
//   }

//   Widget _buildField({required Widget child}) => Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: child,
//       );
//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     body: Center(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Form(
//             key: _formKey,
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 // Title
//                 Text(
//                   'Sign Up',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.headlineLarge?.copyWith(
//                         color: Colors.indigo.shade400,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 32,
//                       ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Row 1: First & Last
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSizedField(controller: _firstNameController, label: 'First Name'),
//                     const SizedBox(width: 16),
//                     _buildSizedField(controller: _lastNameController, label: 'Last Name'),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Row 2: Email & Confirm Email
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSizedField(
//                       controller: _emailController,
//                       label: 'Email',
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (v) {
//                         if (v!.isEmpty) return 'Required';
//                         if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(width: 16),
//                     _buildSizedField(
//                       controller: _confirmEmailController,
//                       label: 'Confirm Email',
//                       keyboardType: TextInputType.emailAddress,
//                       validator: (v) => v != _emailController.text ? 'Does not match' : null,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Row 3: Age & Gender
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSizedField(
//                       controller: _ageController,
//                       label: 'Age',
//                       keyboardType: TextInputType.number,
//                       validator: (v) {
//                         final a = int.tryParse(v!);
//                         if (a == null) return 'requiread';
//                         if (a <= 16) return 'Must be >16';
//                         return null;
//                       },
//                     ),
//                     const SizedBox(width: 16),
//                     SizedBox(
//                       width: 300,
//                       height: 80,
//                       child: _buildField(
//                         child: DropdownButtonFormField<String>(
//                           dropdownColor: Colors.grey[100],
//  style: TextStyle(
//     fontSize: 16,                        // למשל 14 במקום 16
//     color: Colors.indigo.shade900,
//   ),                 
//    selectedItemBuilder: (context) {
//     return ['Male','Female','Other'].map((v) {
//       return Text(v, style: const TextStyle(fontSize: 16, color: Colors.indigo));
//     }).toList();
//   },
//            decoration: InputDecoration(
//                             labelText: 'Gender',
//                             labelStyle: TextStyle(fontSize: 14, color: Colors.indigo.shade400),
//                             border: const OutlineInputBorder(),
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.black),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
//                             ),
//                             errorBorder: const OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.red, width: 1.5),
//                             ),
//                             focusedErrorBorder: const OutlineInputBorder(
//                               borderSide: BorderSide(color: Colors.red, width: 2),
//                             ),
//                             errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
//                             isDense: true,
//                             contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//                             errorMaxLines: 1,
//                           ),
//                           items: ['Male', 'Female', 'Other']
//                               .map((v) {
//                                 return DropdownMenuItem<String>(
//                                   value: v,
//                                   child: MouseRegion(
//                                     onEnter: (_) => setState(() => _hoveredGender = v),
//                                     onExit: (_) => setState(() => _hoveredGender = null),
//                                     child: Container(
//                                       color: _hoveredGender == v
//                                           ? Colors.indigo.shade100
//                                           : Colors.transparent,
//                                       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                                       child: Text(v, style: TextStyle(color: Colors.indigo.shade900)),
//                                     ),
//                                   ),
//                                 );
//                               })
//                               .toList(),
//                           onChanged: (v) => setState(() => _genderController.text = v!),
//                           validator: (v) => v == null ? 'Required' : null,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),

//                 // Row 4: Password & Confirm Password
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildSizedField(
//                       controller: _passwordController,
//                       label: 'Password',
//                       obscureText: _obscurePassword,
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
//                       ),
//                       validator: (v) => v!.length < 8 ? '>=8 chars' : null,
//                     ),
//                     const SizedBox(width: 16),
//                     _buildSizedField(
//                       controller: _confirmPasswordController,
//                       label: 'Confirm Password',
//                       obscureText: _obscureConfirm,
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
//                         onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
//                       ),
//                       validator: (v) => v != _passwordController.text ? 'Does not match' : null,
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),

//                 // Sign Up Button
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _signUp,
//                     child: const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
// child: Text(
//   'Sign Up',
//   style: TextStyle(
//     fontSize: 16,
//     color: Colors.white, // כאן הגדרנו לבן
//   ),
// ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.indigo.shade400,
//                       minimumSize: const Size(200, 40),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }

// // Helper widget
// Widget _buildSizedField({
//   required TextEditingController controller,
//   required String label,
//   TextInputType keyboardType = TextInputType.text,
//   bool obscureText = false,
//   Widget? suffixIcon,
//   String? Function(String?)? validator,
// }) {
//   return SizedBox(
//     width: 300,
//     height: 80,
//     child: _buildField(
//       child: TextFormField(
//         cursorColor: Colors.indigo.shade400,
//         controller: controller,
//         style: const TextStyle(fontSize: 16),
//         keyboardType: keyboardType,
//         obscureText: obscureText,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(fontSize: 14, color: Colors.indigo.shade400),
//           border: const OutlineInputBorder(),
//           enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
//           focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.indigo.shade400, width: 2)),
//           errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.5)),
//           focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
//           errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
//           isDense: true,
//           contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
//           errorMaxLines: 1,
//           suffixIcon: suffixIcon,
//         ),
//         validator: validator,
//       ),
//     ),
//   );
// }
// }
import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/validation.dart';
import 'package:phychological_counselor/frontend/firestore_helper.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _signUp() async {
    final valid = validateStep(
      step: 0,
      context: context,
      firstNameController: _firstNameController,
      lastNameController: _lastNameController,
      emailController: _emailController,
      confirmEmailController: _confirmEmailController,
      ageController: _ageController,
      genderController: _genderController,
      passwordController: _passwordController,
      confirmPasswordController: _confirmPasswordController,
    );

    if (!valid) return;

    if (_emailController.text.trim() != _confirmEmailController.text.trim()) {
_showStyledError('Signup Error', 'Emails do not match.');
      return;
    }

    if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
      _showStyledError('Signup Error', 'Passwords do not match.');
      return;
    }

    await signUpAndSaveUser(
      context: context,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      age: _ageController.text.trim(),
      gender: _genderController.text.trim(),
    );
  }

  void _showStyledError(String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.indigo.shade400,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 16, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK', style: TextStyle(color: Colors.indigo.shade400)),
        ),
      ],
    ),
  );
}

  void _showInlineError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 160,
        title: Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.indigo.shade400,
            fontSize: 50,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_firstNameController, 'First Name')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_lastNameController, 'Last Name')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_emailController, 'Email')),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField(_confirmEmailController, 'Confirm Email')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.grey[200],
                            highlightColor: Colors.indigo.shade100,
                            splashColor: Colors.indigo.shade100,
                            hoverColor: Colors.indigo.shade100,
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _genderController.text.isNotEmpty ? _genderController.text : null,
                            items: ['Male', 'Female', 'Other']
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value, style: TextStyle(fontSize: 16, color: Colors.black)),
                                    ))
                                .toList(),
                            onChanged: (value) => _genderController.text = value ?? '',
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            dropdownColor: Colors.grey[200],
                            iconEnabledColor: Colors.indigo.shade400,
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              labelStyle: const TextStyle(fontSize: 14, color: Colors.black),
                              floatingLabelStyle: TextStyle(fontSize: 14, color: Colors.indigo.shade400),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _passwordController,
                          'Password',
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTextField(
                          _confirmPasswordController,
                          'Confirm Password',
                          obscure: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                    child: const Text('Sign Up', style: TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        cursorColor: Colors.indigo.shade400,
        style: const TextStyle(fontSize: 16, color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 14, color: Colors.black),
          floatingLabelStyle: TextStyle(color: Colors.indigo.shade400, fontSize: 14),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
          ),
        ),
      ),
    );
  }
}