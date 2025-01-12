import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _controllers = [
    TextEditingController(), // First Name
    TextEditingController(), // Last Name
    TextEditingController(), // Email
    TextEditingController(), // Confirm Email
    TextEditingController(), // Age
    TextEditingController(), // Password
    TextEditingController(), // Confirm Password
  ];

  final _errorStates = [false, false, false, false, false, false, false]; // Error states for each field
  int _visibleStep = 0;

  Future<bool> _isEmailUsed(String email) async {
    final users = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    return users.docs.isNotEmpty;
  }

  Future<void> _validateStep(int step) async {
    final controller = _controllers[step];
    String value = controller.text.trim();

    // Validation rules based on the current step
    String? errorMessage;

    switch (step) {
      case 0: // First Name
        if (value.isEmpty) errorMessage = 'First Name is required.';
        break;
      case 1: // Last Name
        if (value.isEmpty) errorMessage = 'Last Name is required.';
        break;
      case 2: // Email
        if (value.isEmpty || !_isValidEmail(value)) {
          errorMessage = 'Enter a valid email address.';
        } else if (await _isEmailUsed(value)) {
          errorMessage = 'Email is already in use.';
        }
        break;
      case 3: // Confirm Email
        if (value != _controllers[2].text) errorMessage = 'Emails do not match.';
        break;
      case 4: // Age
        final age = int.tryParse(value);
        if (age == null || age < 18) {
          errorMessage = 'You must be 18+ to create an account.';
        }
        break;
      case 5: // Password
        if (value.length < 8) {
          errorMessage = 'Password must be at least 8 characters long.';
        }
        break;
      case 6: // Confirm Password
        if (value != _controllers[5].text) {
          errorMessage = 'Passwords do not match.';
        }
        break;
    }

    if (errorMessage != null) {
      // Show error
      _showErrorDialog(errorMessage);
      setState(() {
        _errorStates[step] = true;
      });
    } else {
      // Proceed to next step
      setState(() {
        _errorStates[step] = false;
        if (_visibleStep == step) _visibleStep++;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  Widget _buildAnimatedInputField({
    required String label,
    required TextEditingController controller,
    required int step,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 300),
      opacity: _visibleStep >= step ? 1.0 : 0.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        margin: EdgeInsets.only(top: _visibleStep >= step ? 10.0 : 100.0),
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errorStates[step] ? Colors.red : Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errorStates[step] ? Colors.red : Colors.grey,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _errorStates[step] ? Colors.red : Colors.blue,
              ),
            ),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSubmitted: (_) => _validateStep(step), // Validate on Enter
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
        backgroundColor: Colors.indigo.shade400,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildAnimatedInputField(
                label: 'First Name',
                controller: _controllers[0],
                step: 0,
              ),
              _buildAnimatedInputField(
                label: 'Last Name',
                controller: _controllers[1],
                step: 1,
              ),
              _buildAnimatedInputField(
                label: 'Email',
                controller: _controllers[2],
                step: 2,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildAnimatedInputField(
                label: 'Confirm Email',
                controller: _controllers[3],
                step: 3,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildAnimatedInputField(
                label: 'Age',
                controller: _controllers[4],
                step: 4,
                keyboardType: TextInputType.number,
              ),
              _buildAnimatedInputField(
                label: 'Password',
                controller: _controllers[5],
                step: 5,
                obscureText: true,
              ),
              _buildAnimatedInputField(
                label: 'Confirm Password',
                controller: _controllers[6],
                step: 6,
                obscureText: true,
              ),
              if (_visibleStep >= 6)
                ElevatedButton(
                  onPressed: () => _validateStep(6),
                  child: Text('Sign Up'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
