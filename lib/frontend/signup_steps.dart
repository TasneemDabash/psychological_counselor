// ✅ קובץ: frontend/signup_steps.dart

import 'package:flutter/material.dart';

Widget buildTextField({
  required TextEditingController controller,
  required String label,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label),
    obscureText: obscureText,
    keyboardType: keyboardType,
  );
}

class SignUpSteps extends StatelessWidget {
  final int step;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final TextEditingController confirmEmailController;
  final TextEditingController ageController;
  final TextEditingController genderController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const SignUpSteps({
    required this.step,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.confirmEmailController,
    required this.ageController,
    required this.genderController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case 0:
        return buildTextField(controller: firstNameController, label: 'First Name');
      case 1:
        return buildTextField(controller: lastNameController, label: 'Last Name');
      case 2:
        return Column(
          children: [
            buildTextField(controller: emailController, label: 'Email'),
            SizedBox(height: 10),
            buildTextField(controller: confirmEmailController, label: 'Confirm Email'),
          ],
        );
      case 3:
        return buildTextField(
          controller: ageController,
          label: 'Age',
          keyboardType: TextInputType.number,
        );
      case 4:
        return DropdownButtonFormField<String>(
          value: null,
          items: ['Male', 'Female', 'Other'].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
          onChanged: (value) => genderController.text = value!,
          decoration: InputDecoration(labelText: 'Gender'),
        );
      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField(controller: passwordController, label: 'Password', obscureText: true),
            SizedBox(height: 10),
            buildTextField(controller: confirmPasswordController, label: 'Confirm Password', obscureText: true),
          ],
        );
      default:
        return SizedBox();
    }
  }
}