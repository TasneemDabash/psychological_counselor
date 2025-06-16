// 📄 lib/home/frontend/home_screenDesign.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreenDesign extends StatefulWidget {
  const HomeScreenDesign({super.key});

  @override
  State<HomeScreenDesign> createState() => _HomeScreenDesignState();
}

class _HomeScreenDesignState extends State<HomeScreenDesign> {
  bool _menuOpen = false;
  bool _obscureCurrent = true; 
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _showStatisticsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📊Statistics"),
        content: const Text("כאן יופיעו הנתונים הסטטיסטיים בהמשך..."),
        
      ),
    );
  }

  void _showReportsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("📄Reports"),
        content: const Text("כאן יוצגו דוחות בהמשך..."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("סגור"),
          ),
        ],
      ),
    );
  }


 @override
Widget build(BuildContext context) {
  final user = FirebaseAuth.instance.currentUser;

  return Stack(
    children: [
      Positioned(
        top: 16,
        right: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _menuOpen = !_menuOpen;
                });
              },
             child: Icon(
  Icons.person,
  color: Colors.indigo.shade400, // 💜 הצבע הרצוי
  size: 28,
),
            ),
            if (_menuOpen)
              Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[200],
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.email ?? "לא מחובר",
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _menuItem("⚙️ Settings", () {
                        setState(() => _menuOpen = false);
                        showUserProfileDialog(context);
                      }),
                      _menuItem("📊 Statistics", _showStatisticsDialog),
                      _menuItem("📄 Reports", _showReportsDialog),
                    MouseRegion(
  cursor: SystemMouseCursors.click,
  child: GestureDetector(
    onTap: () {
      FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacementNamed('/');
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text("⎋", style: TextStyle(fontSize: 18, color: Colors.redAccent)),
          SizedBox(width: 8),
          Text("Log Out", style: TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    ),
  ),
),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

Widget _menuItem(String text, VoidCallback onTap, {TextStyle? style}) {
  return MouseRegion(
    cursor: SystemMouseCursors.click, 
    child: GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: style ?? const TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
    ),
  );
}
}

class MyProfileOnly extends StatelessWidget {
  const MyProfileOnly({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: Center(
        child: Text(user?.email ?? "לא מחובר", style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
Future<void> showUserProfileDialog(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final docSnap = await docRef.get();
  final userData = docSnap.data();

  final _nameController = TextEditingController(text: userData?['firstName'] ?? '');
  //final _emailController = TextEditingController(text: userData?['email'] ?? '');
  final _currentPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.grey[300],
          title: const Text('My Profile',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Name'),
                //  _buildTextField(_emailController, 'Email'),
                  const SizedBox(height: 10),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Change Password",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  _buildPasswordField(
                    controller: _currentPassController,
                    label: 'Current Password',
                    obscure: _obscureCurrent,
                    toggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  _buildPasswordField(
                    controller: _newPassController,
                    label: 'New Password',
                    obscure: _obscureNew,
                    toggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  _buildPasswordField(
                    controller: _confirmPassController,
                    label: 'Confirm Password',
                    obscure: _obscureConfirm,
                    toggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
             onPressed: () async {
  final name = _nameController.text.trim();
  //final email = _emailController.text.trim();
  final currentPassword = _currentPassController.text.trim();
  final newPassword = _newPassController.text.trim();
  final confirmPassword = _confirmPassController.text.trim();

  if (name.isEmpty) {
    showError(context, ' The name field cannot be empty.');
    return;
  }
//   if (!isEmailValid(email)) {
//   showError(context, 'The email address is invalid. Please try again.');
//   return;
// }


  try {
if (newPassword.isNotEmpty || confirmPassword.isNotEmpty) {
  if (newPassword.isEmpty) {
    showError(context, 'A new password must be entered before entering password verification.');
    return;
  }
       if (currentPassword.isEmpty) {
    showError(context, 'יש להזין את הסיסמה הנוכחית.');
    return;
  }
      if (currentPassword.isEmpty) {
        showError(context, 'Please enter the current password.');
        return;
      }

      // 🔴 בדיקה: אימות מול Firebase
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);

      // 🔴 בדיקה: התאמה בין הסיסמה החדשה לאימות שלה
      if (newPassword != confirmPassword) {
        showError(context, 'The new password and confirm password do not match.');
        return;
      }

      // 🔴 בדיקה: האם הסיסמה חזקה
      if (!isPasswordStrong(newPassword)) {
        showError(context, 'The password must contain at least 8 characters, letters, numbers & symbols.');
        return;
      }
      

      // ✅ עדכון סיסמה בפועל
      await user.updatePassword(newPassword);
    }
 


    // ✅ עדכון פרטים אחרים (שם, אימייל)
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'firstName': name,
    //  'email': email,
      if (newPassword.isNotEmpty) 'password': newPassword, // זמני
    });

    Navigator.pop(context);
  } catch (e) {
    showError(context, 'Authentication error: The current password is incorrect.');
  }
},

              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.indigo.shade400, fontSize: 18)),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildTextField(TextEditingController controller, String label) {
  return TextField(
    controller: controller,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    ),
  );
}

Widget _buildPasswordField({
  required TextEditingController controller,
  required String label,
  required bool obscure,
  required VoidCallback toggle,
}) {
  return TextField(
    controller: controller,
    obscureText: obscure,
    style: const TextStyle(fontSize: 16),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.indigo)),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: toggle,
      ),
    ),
  );
}

bool isPasswordStrong(String password) {
  final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z\d]).{8,}$');
  return regex.hasMatch(password);
}
 bool isEmailValid(String email) {
  final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return regex.hasMatch(email);
}
void showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.error_outline, color: Colors.redAccent),
          SizedBox(width: 10),
          Text(
            "Error Updating",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 16, color: Colors.black87),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("close", style: TextStyle(color: Colors.indigo,fontSize:16)),
        ),
      ],
    ),
  );
}