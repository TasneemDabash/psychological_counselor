<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _confirmEmailController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;

  Future<void> _signUp() async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'age': int.parse(_ageController.text),
        'gender': _genderController.text,
        'password': _passwordController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up successful!')),
      );

      Navigator.pop(context); // חזרה למסך הקודם לאחר הצלחה
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign Up failed: $e')),
      );
    }
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    setState(() {
      _currentStep++;
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_firstNameController.text.isEmpty) {
          _showError('First name is required');
          return false;
        }
        break;
      case 1:
        if (_lastNameController.text.isEmpty) {
          _showError('Last name is required');
          return false;
        }
        break;
      case 2:
        if (_emailController.text.isEmpty ||
            !_isValidEmail(_emailController.text)) {
          _showError('Valid email is required');
          return false;
        }
        if (_emailController.text != _confirmEmailController.text) {
          _showError('Emails do not match');
          return false;
        }
        break;
      case 3:
        final age = int.tryParse(_ageController.text);
        if (age == null || age <= 16) {
          _showError('Age must be greater than 16');
          return false;
        }
        break;
      case 4:
        if (_genderController.text.isEmpty) {
          _showError('Gender is required');
          return false;
        }
        break;
      case 5:
        if (_passwordController.text.isEmpty ||
            !_isValidPassword(_passwordController.text)) {
          _showError(
              'Password must be at least 8 characters, include a number, and an uppercase letter');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError('Passwords do not match');
          return false;
        }
        break;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _getStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildTextInputStep(
          controller: _firstNameController,
          label: 'First Name',
        );
      case 1:
        return _buildTextInputStep(
          controller: _lastNameController,
          label: 'Last Name',
        );
      case 2:
        return Column(
          children: [
            _buildTextInputStep(
              controller: _emailController,
              label: 'Email',
            ),
            SizedBox(height: 10),
            _buildTextInputStep(
              controller: _confirmEmailController,
              label: 'Confirm Email',
            ),
          ],
        );
      case 3:
        return _buildTextInputStep(
          controller: _ageController,
          label: 'Age',
          keyboardType: TextInputType.number,
        );
      case 4:
        return DropdownButtonFormField<String>(
          value: null,
          items: ['Male', 'Female', 'Other'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (value) {
            _genderController.text = value!;
          },
          decoration: InputDecoration(labelText: 'Gender'),
        );
      case 5:
        return Column(
          children: [
            _buildTextInputStep(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 10),
            _buildTextInputStep(
              controller: _confirmPasswordController,
              label: 'Confirm Password',
              obscureText: true,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  Widget _buildTextInputStep({
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
            Expanded(child: _getStepContent()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
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
=======
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
>>>>>>> 45892dbe463b398cc8270c315b487359cd152f8a
