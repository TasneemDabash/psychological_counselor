// <<<<<<< HEAD
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:phychological_counselor/home/screens/home_screen.dart'; // היבוא של HomeScreen
// import 'package:phychological_counselor/main/navigation/routes/name.dart';
// =======
// ✅ הקובץ הראשי SignUpPage.dart לאחר הפיצול

import 'package:flutter/material.dart';
import 'package:phychological_counselor/frontend/signup_steps.dart';
import 'package:phychological_counselor/frontend/validation.dart';
import 'package:phychological_counselor/frontend/firestore_helper.dart';
import 'package:phychological_counselor/frontend/email_validator.dart';



class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _currentStep = 0;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

// <<<<<<< HEAD
//   Future<void> _signUp() async {
//     try {
//       await FirebaseFirestore.instance.collection('users').add({
//           'firstName': _firstNameController.text.trim(),
//   'lastName': _lastNameController.text.trim(),
//   'email': _emailController.text.trim(),
//   'password': _passwordController.text.trim(),
//         'age': int.parse(_ageController.text),
//         'gender': _genderController.text,
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sign Up successful!')),
//       );

//       Navigator.pushNamedAndRemoveUntil(
//         context,
//  AppRoutes.home,
//   (route) => false,      );

//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Sign Up failed: $e')),
//       );
//     }
//   }

//   void _nextStep() {
//     if (!_validateCurrentStep()) return;

// =======
  void _nextStep() {
    if (!_validateCurrentStep()) return;

    setState(() {
      _currentStep++;
    });
  }

  bool _validateCurrentStep() {
// <<<<<<< HEAD
//     switch (_currentStep) {
//       case 0:
//         if (_firstNameController.text.isEmpty) {
//           _showError('First name is required');
//           return false;
//         }
//         break;
//       case 1:
//         if (_lastNameController.text.isEmpty) {
//           _showError('Last name is required');
//           return false;
//         }
//         break;
//       case 2:
//         if (_emailController.text.isEmpty ||
//             !_isValidEmail(_emailController.text)) {
//           _showError('Valid email is required');
//           return false;
//         }
//         if (_emailController.text != _confirmEmailController.text) {
//           _showError('Emails do not match');
//           return false;
//         }
//         break;
//       case 3:
//         final age = int.tryParse(_ageController.text);
//         if (age == null || age <= 16) {
//           _showError('Age must be greater than 16');
//           return false;
//         }
//         break;
//       case 4:
//         if (_genderController.text.isEmpty) {
//           _showError('Gender is required');
//           return false;
//         }
//         break;
//       case 5:
//         if (_passwordController.text.isEmpty ||
//             !_isValidPassword(_passwordController.text)) {
//           _showError(
//               'Password must be at least 8 characters, include a number, and an uppercase letter');
//           return false;
//         }
//         if (_passwordController.text != _confirmPasswordController.text) {
//           _showError('Passwords do not match');
//           return false;
//         }
//         break;
//     }
//     return true;
//   }

//   bool _isValidEmail(String email) {
//     final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
//     return emailRegex.hasMatch(email);
//   }

//   bool _isValidPassword(String password) {
//     return password.length >= 8 &&
//         RegExp(r'[A-Z]').hasMatch(password) &&
//         RegExp(r'[0-9]').hasMatch(password);
//   }

//   void _showError(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   Widget _getStepContent() {
//     switch (_currentStep) {
//       case 0:
//         return _buildTextInputStep(
//           controller: _firstNameController,
//           label: 'First Name',
//         );
//       case 1:
//         return _buildTextInputStep(
//           controller: _lastNameController,
//           label: 'Last Name',
//         );
//       case 2:
//         return Column(
//           children: [
//             _buildTextInputStep(
//               controller: _emailController,
//               label: 'Email',
//             ),
//             SizedBox(height: 10),
//             _buildTextInputStep(
//               controller: _confirmEmailController,
//               label: 'Confirm Email',
//             ),
//           ],
//         );
//       case 3:
//         return _buildTextInputStep(
//           controller: _ageController,
//           label: 'Age',
//           keyboardType: TextInputType.number,
//         );
//       case 4:
//         return DropdownButtonFormField<String>(
//           value: null,
//           items: ['Male', 'Female', 'Other'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (value) {
//             _genderController.text = value!;
//           },
//           decoration: InputDecoration(labelText: 'Gender'),
//         );
//       case 5:
//         return Column(
//           children: [
//             _buildTextInputStep(
//               controller: _passwordController,
//               label: 'Password',
//               obscureText: true,
//             ),
//             SizedBox(height: 10),
//             _buildTextInputStep(
//               controller: _confirmPasswordController,
//               label: 'Confirm Password',
//               obscureText: true,
//             ),
//           ],
//         );
//       default:
//         return Container();
//     }
//   }

//   Widget _buildTextInputStep({
//     required TextEditingController controller,
//     required String label,
//     bool obscureText = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(labelText: label),
//       obscureText: obscureText,
//       keyboardType: keyboardType,
// =======
    return validateStep(
      step: _currentStep,
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
  }

  void _signUp() async {
    final email = _emailController.text.trim();

  // שלב 1: בדיקה אם האימייל אמיתי ונשלח
  final isValid = await isRealEmail(email);
  if (!isValid) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('האימייל אינו תקף או לא ניתן לשלוח אליו')),
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
// <<<<<<< HEAD
//             Expanded(child: _getStepContent()),
// =======
            Expanded(
              child: SignUpSteps(
                step: _currentStep,
                firstNameController: _firstNameController,
                lastNameController: _lastNameController,
                emailController: _emailController,
                confirmEmailController: _confirmEmailController,
                ageController: _ageController,
                genderController: _genderController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
// <<<<<<< HEAD
//                     onPressed: () {
//                       setState(() {
//                         _currentStep--;
//                       });
//                     },
// =======
                    onPressed: () => setState(() => _currentStep--),

                    child: Text('Back'),
                  ),
                ElevatedButton(
                  onPressed: _currentStep == 5 ? _signUp : _nextStep,
                  child: Text(_currentStep == 5 ? 'Finish' : 'Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
